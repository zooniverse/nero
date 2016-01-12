require_relative 'pulsar_hunters_classification'
require_relative 'pulsar_hunters_estimate'

module Nero
  module PulsarHunters
    class PulsarHuntersAlgorithm < Nero::Algorithm
      def process(classification, agent, estimate)
        return unless classification.subject_ids.size == 1

        classification = Nero::PulsarHunters::PulsarHuntersClassification.new(classification)
        estimate = Nero::PulsarHunters::PulsarHuntersEstimate.new(estimate)
        estimate.add(classification.id)
        @storage.record_estimate(estimate)

        if classification.subjects[0].gold_standard?
          @panoptes.retire(estimate) if estimate.classifications_count >= @options.fetch("gold_standard_limit")
        else
          @panoptes.retire(estimate) if estimate.classifications_count >= @options.fetch("normal_limit")
        end
      end
    end
  end
end
