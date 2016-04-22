require 'ostruct'
require_relative 'swap_user_state'
require_relative 'swap_subject'
require_relative 'swap_classification'
require_relative 'swap_estimate'

module Nero
  module Swap
    class SwapAlgorithm < Nero::Algorithm
      def process(classification, user_state, estimate)
        return unless classification.user_id

        classification = SwapClassification.new(classification)
        user_state = SwapUserState.new(user_state)
        estimate = SwapEstimate.new(estimate)

        classification.subjects.map do |subject|
          if estimate.retired? && subject.test?
            next estimate
          end

          if subject.test? || estimate.active?
            estimate.adjust(user_state, classification.guess)
            user_state.update_confusion_unsupervised(classification.guess, estimate.probability)
            @storage.record_user_state(user_state)
            @storage.record_estimate(estimate)
          else # training subject or retired already
            user_state.update_confusion_unsupervised(classification.guess, estimate.probability)
            @storage.record_user_state(user_state)
          end

          if estimate.retired? && subject.test?
            @panoptes.retire(estimate)
            # if estimate.seen_by?(workflow.skilled_agents)
            #   @panoptes.retire(estimate)
            # else
            #   @panoptes.enqueue(workflow.skilled_agents)
            # end
          end

          estimate
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
