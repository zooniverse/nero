require_relative 'survey_classification'
require_relative 'survey_subject_state'
require_relative 'survey_rules'

module Nero
  module Survey
    class SurveyAlgorithm < Nero::Algorithm
      def process(classification, user_state, subject_state)
        super(classification, user_state, subject_state)
        return unless classification.subject_ids.size == 1

        classification = Nero::Survey::SurveyClassification.new(classification)
        subject_state = Nero::Survey::SurveySubjectState.new(subject_state)
        subject_state.add_vote(classification.id, classification.vote(task_key))
        @storage.record_subject_state(subject_state)

        case retired?(subject_state)
        when :human, :vehicle
          @panoptes.retire(subject_state, reason: 'other')
        when :flagged
          @panoptes.retire(subject_state, reason: 'flagged')
        when :blank, :blank_consensus
          @panoptes.retire(subject_state, reason: 'blank')
        when :consensus
          @panoptes.retire(subject_state, reason: 'consensus')
        end
      end

      def retired?(subject_state)
        rules.apply_to(subject_state.results)
      end

      def rules
        @rules ||= Nero::Survey::SurveyRules.new(options)
      end

      def task_key
        options.fetch('task_key', "T0")
      end

      def consensus_limit
        options.fetch('consensus_limit', 7)
      end

      def human_limit
        options.fetch('human_limit', 1)
      end

      def flagged_limit
        options.fetch('flagged_limit', 1)
      end

      def blank_limit
        options.fetch('blank_limit', 3)
      end

      def blank_consensus_limit
        options.fetch('blank_consensus_limit', 5)
      end
    end
  end
end
