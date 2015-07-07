require 'set'

module RetirementSwap
  module Storage
    class Memory
      attr_reader :most_recent_estimates, :all_estimates, :agents

      def initialize
        @most_recent_estimates = {}
        @all_estimates = []
        @agents = {}
      end

      def find_agent(user_id)
        @agents[user_id] ||= Agent.new(user_id)
      end

      def find_estimate(subject_id, workflow_id)
        most_recent_estimates["#{subject_id}-#{workflow_id}"] || RetirementSwap::Estimate.new(subject_id, workflow_id)
      end

      def record_estimate(estimate)
        most_recent_estimates["#{estimate.subject_id}-#{estimate.workflow_id}"] = estimate
        all_estimates << estimate
      end
    end
  end
end
