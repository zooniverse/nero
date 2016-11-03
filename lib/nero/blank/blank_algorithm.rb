require_relative 'blank_classification'
require_relative 'blank_subject_state'

module Nero
  module Blank
    class BlankAlgorithm < Nero::Algorithm
      def process(classification, user_state, subject_state)
        super(classification, user_state, subject_state)
        return unless classification.user_id
        return unless classification.subject_ids.size == 1

        classification = Nero::Blank::BlankClassification.new(classification)
        subject_state = Nero::Blank::BlankSubjectState.new(subject_state)
        subject_state.add_vote(classification.id, classification.vote(task_key))
        @storage.record_subject_state(subject_state)

        if subject_state.retired?(blank_consensus_limit) == :blank_consensus
          @panoptes.retire(subject_state, reason: 'blank')
        end
      end

      private

      def task_key
        options.fetch('task_key', 'T0')
      end

      def blank_consensus_limit
        options.fetch('blank_consensus_limit', 5)
      end
    end
  end
end
