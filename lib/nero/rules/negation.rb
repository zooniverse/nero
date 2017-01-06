module Nero
  module Rules
    class Negation
      def initialize(operation)
        @operation = operation
      end

      def apply(bindings)
        !@operation.apply(bindings)
      end
    end
  end
end
