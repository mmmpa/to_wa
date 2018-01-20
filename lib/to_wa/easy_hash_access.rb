module ToWa
  module EasyHashAccess
    refine Hash do
      def k
        keys.first
      end

      def v
        values.first
      end
    end
  end
end
