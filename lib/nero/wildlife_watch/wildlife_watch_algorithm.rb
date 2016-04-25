require_relative 'wildlife_watch_classification'
require_relative 'wildlife_watch_subject_state'

module Nero
  module WildlifeWatch
    class WildlifeWatchAlgorithm < Nero::Algorithm
      def process(classification, user_state, subject_state)
        super(classification, user_state, subject_state)
        return unless classification.user_id
        return unless classification.subject_ids.size == 1

        classification = Nero::WildlifeWatch::WildlifeWatchClassification.new(classification)
        subject_state = Nero::WildlifeWatch::WildlifeWatchSubjectState.new(subject_state)
        subject_state.add_vote(classification.vote)
        @storage.record_subject_state(subject_state)

        if subject_state.retired?
          @panoptes.retire(subject_state)
        end
      end
    end
  end
end
