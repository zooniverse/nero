require_relative 'transcribe_hack_classification'
require_relative 'transcribe_hack_subject_state'

module Nero
  module TranscribeHack
    class TranscribeHackAlgorithm < Nero::Algorithm
      def process(classification, user_state, subject_state)
        super(classification, user_state, subject_state)
        return unless classification.user_id
        return unless classification.subject_ids.size == 1

        classification = Nero::TranscribeHack::TranscribeHackClassification.new(classification)
        subject_state = Nero::TranscribeHack::TranscribeHackSubjectState.new(subject_state)
        subject_state.add_vote(classification.id, classification.vote)
        @storage.record_subject_state(subject_state)

        if subject_state.retired?
          #@panoptes.retire(subject_state)
          subject_set_id = 6236
          @panoptes.add_subjects_to_subject_set(subject_set_id, classification.subject_ids)
        end
      end
    end
  end
end
