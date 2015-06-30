require 'set'

module RetirementSwap
  module Storage
    class Memory
      def initialize
        @memory = {}
      end

      def record_classification(subject_id, user_id)
        key = key_for(subject_id)
        @memory[key] ||= Set.new
        @memory[key].add(user_id)

        {number_of_classifications: @memory[key].size}
      end

      def key_for(subject_id)
        "subject-#{subject_id}-seen-by"
      end
    end
  end
end
