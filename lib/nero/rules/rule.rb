require_relative 'comparison'
require_relative 'conjunction'
require_relative 'constant'
require_relative 'disjunction'
require_relative 'lookup'
require_relative 'negation'

module Nero
  module Rules
    class Rule
      attr_reader :condition, :effects

      def initialize(condition, effects)
        @condition = condition
        @effects = effects
      end

      def process(results)
        if condition.apply(results)
          effects.each { |effect| effect.perform }
        end
      end
    end
  end
end
