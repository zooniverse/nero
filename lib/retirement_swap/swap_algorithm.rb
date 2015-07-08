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
        estimate = @storage.find_estimate(subject.id, classification.workflow_id)

        if estimate.status != :active and subject.category == 'test'
          next estimate
        end

        unless subject.category == "training" && estimate.status != :active
          new_estimate = estimate.adjust(agent, classification.guess)
          agent.update_confusion_unsupervised(classification.guess, new_estimate.probability)
        else
          new_estimate = estimate
          agent.update_confusion_unsupervised(classification.guess, new_estimate.probability)
        end

        @storage.record_agent(agent)
        @storage.record_estimate(new_estimate)
        new_estimate
      end
    end
  end
end
