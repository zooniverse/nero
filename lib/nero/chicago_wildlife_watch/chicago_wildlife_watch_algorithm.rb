require_relative 'chicago_wildlife_watch_classification'
require_relative 'chicago_wildlife_watch_subject_state'

module Nero
  module ChicagoWildlifeWatch
    class ChicagoWildlifeWatchAlgorithm < Nero::Algorithm
      def process(classification, user_state, subject_state)
        super(classification, user_state, subject_state)
        return unless classification.subject_ids.size == 1

        classification = Nero::ChicagoWildlifeWatch::ChicagoWildlifeWatchClassification.new(classification)
        subject_state = Nero::ChicagoWildlifeWatch::ChicagoWildlifeWatchSubjectState.new(subject_state)
        subject_state.add_vote(classification.vote)
        @storage.record_subject_state(subject_state)

        case subject_state.retired?
        when :human
          @panoptes.retire(subject_state, reason: 'other')
        when :flagged
          @panoptes.retire(subject_state, reason: 'flagged')
        when :three_blanks, :five_blanks
          @panoptes.retire(subject_state, reason: 'blank')
        when :consensus
          @panoptes.retire(subject_state, reason: 'consensus')
        end
      end
    end
  end
end
