require 'json'
require 'active_record'

# rubocop:disable Metrics/ClassLength
module ToWa
  class Builder
    using ::ToWa::EasyHashAccess
    include ActiveRecord::Sanitization

    # rubocop:disable Metrics/ParameterLists
    def initialize(
      ex:,
      arel_table:,
      restricted: true,
      permitted_columns: Set.new,
      permitted_operators: Set.new,
      permitted_specified_columns: {}
    )
      @restricted = restricted
      @arel_table = arel_table
      @initial_ex = ex.is_a?(String) ? JSON.parse(ex) : ex
      @permitted_columns = permitted_columns
      @permitted_operators = permitted_operators
      @permitted_specified_columns = permitted_specified_columns
    end
    # rubocop:enable Metrics/ParameterLists

    def self.like(v)
      sanitize_sql_like(v)
    end

    def execute!
      decide(@initial_ex)
    end

    private

    def restricted?
      @restricted
    end

    def permitted_columns?(v)
      return true unless restricted?
      @permitted_columns.include?(v)
    end

    def permitted_operators?(v)
      return true unless restricted?
      @permitted_operators.include?(v)
    end

    def decide(ex)
      op = detect_op!(ex.k)
      lr_or_exes = ex.v

      case op
      when 'not'
        decide(lr_or_exes.first).not
      when 'and', 'or'
        add_logic(op, lr_or_exes)
      when 'between'
        between_to_gteq_and_lteq(*lr_or_exes)
      else
        add_comparison(op, *lr_or_exes)
      end
    end

    def detect_op!(op)
      sop = op.to_s
      raise ::ToWa::DeniedOperator, sop unless permitted_operators?(sop)
      ::ToWa::Core::OPERATORS[sop]
    end

    def add_comparison(op, left, right)
      normalize_value(left) { normalize_left_table(left) }.send(op, normalize_right(op, right))
    end

    def between_to_gteq_and_lteq(left, right)
      decide(
        'and' => [
          { '>=' => [left, right.first] },
          { '<=' => [left, right.second] },
        ],
      )
    end

    def normalize_left_table(left)
      raise ::ToWa::DeniedColumn, left unless permitted_columns?(left)
      @arel_table[left]
    end

    def normalize_value(o, &block)
      case
      when o.is_a?(Hash) && o.k.to_s == 'col'
        specify_columns(*o.v.map(&:to_s))
      when block_given?
        block&.call
      else
        o
      end
    end

    def all_specified_columns_allowed?
      @permitted_specified_columns == ::ToWa::AllSpecifiedColumnsAllowance
    end

    def permitted_specified_columns?(table, column)
      return true unless restricted?
      return true if all_specified_columns_allowed?

      @permitted_specified_columns[table]&.include?(column)
    end

    def specify_columns(table, column)
      raise ::ToWa::DeniedColumn, [table, column] unless permitted_specified_columns?(table, column)

      Arel::Table.new(table)[column]
    end

    def normalize_right(op, right)
      if op == 'matches'
        "%#{ToWa::Builder.like(right)}%"
      else
        normalize_value(right)
      end
    end

    def add_logic(op, exes)
      logic = exes[1..-1].inject(decide(exes.first)) { |a, ex| a.send(op, decide(ex)) }
      Arel::Nodes::Grouping.new(logic)
    end
  end
end
# rubocop:enable Metrics/ClassLength
