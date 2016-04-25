require_relative 'equador_classification'
require_relative 'equador_subject_state'

module Nero
  module Equador
    class EquadorAlgorithm < Nero::Algorithm
      def process(classification, _user_state, subject_state)
        return unless classification.user_id
        return unless classification.subject_ids.size == 1

        classification = Nero::Equador::EquadorClassification.new(classification)
        subject_state = Nero::Equador::EquadorSubjectState.new(subject_state)
        subject_state.add_vote(classification.id, classification.vote)
        @storage.record_subject_state(subject_state)

        if subject_state.retired?
          @panoptes.retire(subject_state)
        end
      end
    end
  end
end
