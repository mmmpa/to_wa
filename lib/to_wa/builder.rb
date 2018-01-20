require 'json'

module ToWa
  module Builder
    include ActiveRecord::Sanitization

    def to_wa(ar, ex)
      ar.where(to_wa_raw(ar.arel_table, ex))
    end

    def to_wa_raw(arel_table = nil, ex)
      decide(arel_table, ex.is_a?(String) ? JSON.parse(ex) : ex)
    end

    def decide(arel_table, ex)
      op = ::ToWa::Core::OPERATORS[ex.keys.first.to_s]
      values = ex.values.first

      case op
      when 'not'
        decide(arel_table, values.first).not
      when 'and', 'or'
        add_logic(arel_table, op, values)
      else
        add_comparison(arel_table, op, *values)
      end
    end

    def add_comparison(arel_table, op, table, value)
      normalized =
        case op
        when 'between'
          value.first..value.second
        when 'matches'
          "%#{ToWa::Builder.like(value)}%"
        else
          value
        end

      arel_table[table].send(op, normalized)
    end

    def add_logic(arel_table, op, exes)
      logics =
        exes.inject(nil) do |a, ex|
          a.nil? ? decide(arel_table, ex) : a.send(op, decide(arel_table, ex))
        end

      (exes.size == 1) ? logics : Arel::Nodes::Grouping.new(logics)
    end

    def self.like(v)
      sanitize_sql_like(v)
    end
  end
end
