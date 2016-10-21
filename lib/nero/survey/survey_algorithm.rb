require_relative 'survey_classification'
require_relative 'survey_subject_state'

module Nero
  module Survey
    class SurveyAlgorithm < Nero::Algorithm
      def process(classification, user_state, subject_state)
        super(classification, user_state, subject_state)
        return unless classification.subject_ids.size == 1

        classification = Nero::Survey::SurveyClassification.new(classification)
        subject_state = Nero::Survey::SurveySubjectState.new(subject_state)
        subject_state.add_vote(classification.vote)
        @storage.record_subject_state(subject_state)

        case retired?(subject_state)
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

      def retired?(subject_state)
        return :consensus    if subject_state.vote_counts.any? { |_, count| count >= 7 } # If 7 users have annotated the same animal, retire it.
        return :human        if subject_state.vote_counts["human"] >= 1                  # If anyone has annotated a human, retire it.
        return :flagged      if subject_state.vote_counts["reported"] >= 1               # If anyone has annotated the subject as ‘Report this photo’, retire it.
        return :three_blanks if subject_state.votes[0..2].count("blank") == 3            # If the first three users annotated the subject as blank, retire it.
        return :five_blanks  if subject_state.vote_counts["blank"] >= 5                  # If 5 users annotated the subject as blank, retire it.
        false # leaving the 15 classifications limit up to panoptes
      end
    end
  end
end
