module RetirementSwap
  class SimpleRetirement
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
        result = @storage.record_classification(subject_id, user_id)

        if result[:number_of_classifications] >= @threshold
          @panoptes.retire(subject: subject_id, subject_set: :todo, workflow: workflow_id)
        end
      end
    end
  end
end
