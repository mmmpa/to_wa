require 'json'
require 'active_record'

module ToWa
  module Builder
    using ::ToWa::EasyHashAccess
    include ActiveRecord::Sanitization

    def self.like(v)
      sanitize_sql_like(v)
    end

    def to_wa(ar, ex)
      ar.where(to_wa_raw(ar.arel_table, ex))
    end

    def to_wa_raw(arel_table, ex)
      decide(arel_table, ex.is_a?(String) ? JSON.parse(ex) : ex)
    end

    private

    def decide(arel_table, ex)
      op = detect_op!(ex.k)
      lr_or_exes = ex.v

      case op
      when 'not'
        decide(arel_table, lr_or_exes.first).not
      when 'and', 'or'
        add_logic(arel_table, op, lr_or_exes)
      when 'between'
        between_to_gteq_and_lteq(arel_table, *lr_or_exes)
      else
        add_comparison(arel_table, op, *lr_or_exes)
      end
    end

    def detect_op!(op)
      ::ToWa::Core::OPERATORS[op.to_s]
    end

    def add_comparison(arel_table, op, left, right)
      normalize_value(left) { arel_table[left] }.send(op, normalize_right(op, right))
    end

    def between_to_gteq_and_lteq(arel_table, left, right)
      decide(arel_table, {
        'and' => [
          { '>=' => [left, right.first] },
          { '<=' => [left, right.second] },
        ],
      })
    end

    def normalize_value(o, &block)
      case
      when o.is_a?(Hash) && o.k.to_s == 'col'
        Arel::Table.new(o.v.first)[o.v.second]
      when block_given?
        block&.call
      else
        o
      end
    end

    def normalize_right(op, right)
      if op == 'matches'
        "%#{ToWa::Builder.like(right)}%"
      else
        normalize_value(right)
      end
    end

    def add_logic(arel_table, op, exes)
      logic = exes[1..-1].inject(decide(arel_table, exes.first)) { |a, ex| a.send(op, decide(arel_table, ex)) }
      Arel::Nodes::Grouping.new(logic)
    end
  end
end
