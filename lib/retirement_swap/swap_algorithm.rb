module RetirementSwap
  class SwapAlgorithm
    def initialize(storage, panoptes, threshold: 10)
      @storage = storage
      @panoptes = panoptes
      @threshold = threshold
    end

    def process(classification)
      subject_ids = classification.fetch("links").fetch("subjects")
      user_id = classification.fetch("links").fetch("user")
      workflow_id = classification.fetch("links").fetch("workflow")

      return unless user_id

      subject_ids.each do |subject_id|
        subject = @storage.find_subject(subject_id)
        estimate = @storage.find_estimate(subject_id, workflow_id)
        result = @storage.record_estimate(estimate)
      end
    end
  end
end
