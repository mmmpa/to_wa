require 'json'

module ToWa
  module Configuration
    def permit_to_wa_columns(*columns)
      @permitted_to_wa_columns = Set.new(columns.map(&:to_s))
    end

    def permit_all_to_wa_columns!
      @permitted_to_wa_columns = Set.new(self.column_names)
    end

    def permit_to_wa_specified_columns(hash)
      @permitted_to_wa_specified_columns =
        JSON.parse(hash.to_json).inject({}) { |a, (k, v)| a.merge!(k => Set.new(Array(v))) }
    end

    def permit_all_to_wa_specified_columns!
      @permitted_to_wa_specified_columns = ::ToWa::AllSpecifiedColumnsAllowance
    end

    def permit_to_wa_operators(*operators)
      @permitted_to_wa_operators = Set.new(operators.map(&:to_s))
    end

    def permit_all_to_wa_operators!
      @permitted_to_wa_operators = ToWa::Core::OPERATORS
    end

    def permitted_to_wa_columns
      @permitted_to_wa_columns ||= Set.new
    end

    def permitted_to_wa_specified_columns
      @permitted_to_wa_specified_columns ||= {}
    end

    def permitted_to_wa_operators
      @permitted_to_wa_operators ||= Set.new
    end
  end

  module AllSpecifiedColumnsAllowance
  end
end
