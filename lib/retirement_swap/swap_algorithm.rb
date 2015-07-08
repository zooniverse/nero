module RetirementSwap
  class SwapAlgorithm
    def initialize(storage, panoptes)
      @storage = storage
      @panoptes = panoptes
    end

    def process(hash)
      classification = Classification.new(hash)
      return unless classification.user_id

      agent = @storage.find_agent(classification.user_id)

      classification.subjects.map do |subject|
        old_estimate = @storage.find_estimate(subject.id, classification.workflow_id)

        if old_estimate.status != :active and subject.category == 'test'
          next old_estimate
        end

        unless subject.category == "training" && old_estimate.status != :active
          new_estimate = old_estimate.adjust(agent, classification.guess)
          agent.update_confusion_unsupervised(classification.guess, new_estimate.probability)
        else
          new_estimate = old_estimate
          agent.update_confusion_unsupervised(classification.guess, new_estimate.probability)
        end

        @storage.record_agent(agent)
        @storage.record_estimate(new_estimate)
        new_estimate
      end
    end
  end
end
