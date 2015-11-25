require 'ostruct'
require_relative 'swap_agent'
require_relative 'swap_subject'
require_relative 'swap_classification'
require_relative 'swap_estimate'

module Nero
  module Swap
    class SwapAlgorithm
      def initialize(storage, panoptes)
        @storage = storage
        @panoptes = panoptes
      end

      def process(classification, agent, estimate)
        return unless classification.user_id

        classification = SwapClassification.new(classification)
        agent = SwapAgent.new(agent)
        estimate = SwapEstimate.new(estimate)

        classification.subjects.map do |subject|
          if estimate.retired? && subject.test?
            next estimate
          end

          if subject.test? || estimate.active?
            estimate.adjust(agent, classification.guess)
            agent.update_confusion_unsupervised(classification.guess, estimate.probability)
            @storage.record_agent(agent)
            @storage.record_estimate(estimate)
          else # training subject or retired already
            agent.update_confusion_unsupervised(classification.guess, estimate.probability)
            @storage.record_agent(agent)
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
        skilled_agents = agents.where(data_column.get_text('skill').cast(Float) > 0.8).map { |i| i[:external_id] }
        OpenStruct.new(skilled_agents: skilled_agents)
      end

      def agents
        @storage.db[:agents]
      end
    end
  end
end
