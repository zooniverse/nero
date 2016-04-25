require_relative 'pulsar_hunters_classification'
require_relative 'pulsar_hunters_subject_state'

module Nero
  module PulsarHunters
    class PulsarHuntersAlgorithm < Nero::Algorithm
      def process(classification, user_state, subject_state)
        super(classification, user_state, subject_state)
        return unless classification.subject_ids.size == 1

        classification = Nero::PulsarHunters::PulsarHuntersClassification.new(classification)
        subject_state = Nero::PulsarHunters::PulsarHuntersSubjectState.new(subject_state)
        subject_state.add(classification.id)
        @storage.record_subject_state(subject_state)

        if classification.subjects[0].gold_standard?
          @panoptes.retire(subject_state) if subject_state.classifications_count >= @options.fetch("gold_standard_limit")
        else
          @panoptes.retire(subject_state) if subject_state.classifications_count >= @options.fetch("normal_limit")
        end
      end
    end
  end
end
