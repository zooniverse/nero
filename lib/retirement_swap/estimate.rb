module RetirementSwap
  class Estimate
    INITIAL_PRIOR = 2e-4

    attr_reader :subject_id, :workflow_id, :kind, :category, :status, :probability

    def initialize(subject_id, workflow_id)
      @subject_id = subject_id
      @workflow_id = workflow_id
      @kind = "unknown"
      @category = "test"
      @status = "active"
      @probability = INITIAL_PRIOR
    end
  end
end
