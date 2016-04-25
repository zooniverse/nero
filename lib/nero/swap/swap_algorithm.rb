require 'ostruct'
require_relative 'swap_user_state'
require_relative 'swap_subject'
require_relative 'swap_classification'
require_relative 'swap_subject_state'

module Nero
  module Swap
    class SwapAlgorithm < Nero::Algorithm
      def process(classification, user_state, subject_state)
        return unless classification.user_id

        classification = SwapClassification.new(classification)
        user_state = SwapUserState.new(user_state)
        subject_state = SwapSubjectState.new(subject_state)

        classification.subjects.map do |subject|
          if subject_state.retired? && subject.test?
            next subject_state
          end

          if subject.test? || subject_state.active?
            subject_state.adjust(user_state, classification.guess)
            user_state.update_confusion_unsupervised(classification.guess, subject_state.probability)
            @storage.record_user_state(user_state)
            @storage.record_subject_state(subject_state)
          else # training subject or retired already
            user_state.update_confusion_unsupervised(classification.guess, subject_state.probability)
            @storage.record_user_state(user_state)
          end

          if subject_state.retired? && subject.test?
            @panoptes.retire(subject_state)
            # if subject_state.seen_by?(workflow.skilled_agents)
            #   @panoptes.retire(subject_state)
            # else
            #   @panoptes.enqueue(workflow.skilled_agents)
            # end
          end

          subject_state
        end
      end

      def workflow
        data_column = Sequel.pg_json_op(:data)
        skilled_agents = user_states.where(data_column.get_text('skill').cast(Float) > 0.8).map { |i| i[:external_id] }
        OpenStruct.new(skilled_agents: skilled_agents)
      end

      def user_states
        @storage.db[:agents]
      end
    end
  end
end
