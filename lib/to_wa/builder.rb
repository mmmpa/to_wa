require 'json'

module ToWa
  module Builder
    include ActiveRecord::Sanitization

    def to_wa(ar, ex)
      ar.where(decide(ar, ex.is_a?(String) ? JSON.parse(ex) : ex))
    end

    def decide(ar, ex)
      op = ::ToWa::Core::OPERATORS[ex.keys.first.to_s]
      values = ex.values.first

      case op
      when 'not'
        decide(ar, values.first).not
      when 'and', 'or'
        add_logic(ar, op, values)
      else
        add_comparison(ar, op, *values)
      end
    end

    def add_comparison(ar, op, table, value)
      normalized =
        case op
        when 'between'
          value.first..value.second
        when 'matches'
          "%#{ToWa::Builder.like(value)}%"
        else
          value
        end

      ar.arel_table[table].send(op, normalized)
    end

    def add_logic(ar, op, exes)
      logics =
        exes.inject(nil) do |a, ex|
          a.nil? ? decide(ar, ex) : a.send(op, decide(ar, ex))
        end

      (exes.size == 1) ? logics : Arel::Nodes::Grouping.new(logics)
    end

    def self.like(v)
      sanitize_sql_like(v)
    end
  end
end
