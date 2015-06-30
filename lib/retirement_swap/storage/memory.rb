require 'set'

module RetirementSwap
  module Storage
    class Memory
      attr_reader :most_recent_estimates, :all_estimates

      def initialize(training_subjects = {})
        @most_recent_estimates = {}
        @all_estimates = []
        @training_subjects = training_subjects
      end

      def find_subject(subject_id)
        @training_subjects[subject_id] || RetirementSwap::Subject.new(subject_id)
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
