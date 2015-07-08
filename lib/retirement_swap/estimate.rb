module RetirementSwap
  class Estimate
    INITIAL_PRIOR = 2e-4
    REJECTION_THRESHOLD = 1e-07
    DETECTION_THRESHOLD = 0.95

    attr_reader :subject_id, :workflow_id, :user_id, :answer, :probability

    def initialize(subject_id, workflow_id, user_id = nil, answer = nil, probability = INITIAL_PRIOR)
      @subject_id = subject_id
      @workflow_id = workflow_id
      @user_id = user_id
      @answer = answer
      @probability = probability
    end

    def attributes
      {
        subject_id: subject_id,
        workflow_id: workflow_id,
        user_id: user_id,
        answer: answer,
        probability: probability
      }
    end

    def adjust(agent, guess)
      pl = agent.pl
      pd = agent.pd

      if guess=="LENS"
        likelihood = pl
        likelihood /= (pl*probability + (1-pd)*(1-probability))
      else
        likelihood = (1-pl)
        likelihood /= ((1-pl)*probability + pd*(1-probability))
      end

      Estimate.new(subject_id, workflow_id, agent.external_id, guess, likelihood * probability)
    end

    def status
      case
      when rejected?
        :rejected
      when detected?
        :detected
      else
        :active
      end
    end

    private

    def rejected?
      probability < REJECTION_THRESHOLD
    end

    def detected?
      probability > DETECTION_THRESHOLD
    end
  end
end
