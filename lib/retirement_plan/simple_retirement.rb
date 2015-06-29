module RetirementPlan
  class SimpleRetirement
    def initialize(storage, panoptes, threshold: 10)
      @storage = storage
      @panoptes = panoptes
      @threshold = threshold
    end

    def process(classification)
      result = @storage.record_classification(classification[:subject_id], classification[:user_id])

      if result[:number_of_classifications] >= @threshold
        @panoptes.retire(subject: classification[:subject_id], workflow: classification[:workflow_id])
      end
    end

    def redis_set_name(classification)
      "subject-#{classification[:subject_id]}-seen-by"
    end
  end
end
