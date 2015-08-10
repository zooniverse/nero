require 'ostruct'
require 'nero/swap/swap_agent'

module Nero
  class SwapAlgorithm
    def initialize(storage, panoptes)
      @storage = storage
      @panoptes = panoptes
    end

    def process(classification, agent, old_estimate)
      return unless classification.user_id

      agent = Nero::Swap::SwapAgent.new(agent)

      classification.subjects.map do |subject|
        if old_estimate.retired? && subject.test?
          next old_estimate
        end

        if subject.test? || old_estimate.active?
          new_estimate = old_estimate.adjust(agent, classification.guess)
          agent.update_confusion_unsupervised(classification.guess, new_estimate.probability)
        else # training subject or retired already
          new_estimate = old_estimate
          agent.update_confusion_unsupervised(classification.guess, new_estimate.probability)
        end

        @storage.record_agent(agent)
        @storage.record_estimate(new_estimate)

        if new_estimate.retired? && subject.test?
          # if new_estimate.seen_by?(workflow.skilled_agents)
            @panoptes.retire(new_estimate)
          # else
            # @panoptes.enqueue(workflow.skilled_agents)
          # end
        end

        new_estimate
      end
    end

    def workflow
      data_column = Sequel.pg_json_op(:data)
      skilled_agents = agents.where(data_column.get_text('skill').cast(Float) > 0.8).map{|i| i[:external_id] }
      OpenStruct.new(skilled_agents: skilled_agents)
    end

    def agents
      @storage.db[:agents]
    end
  end
end
