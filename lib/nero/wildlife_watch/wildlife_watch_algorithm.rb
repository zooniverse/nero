require_relative 'wildlife_watch_classification'
require_relative 'wildlife_watch_estimate'

module Nero
  module WildlifeWatch
    class WildlifeWatchAlgorithm
      def initialize(storage, panoptes)
        @storage = storage
        @panoptes = panoptes
      end

      def process(classification, agent, estimate)
        return unless classification.user_id
        return unless classification.subject_ids.size == 1

        classification = Nero::WildlifeWatch::WildlifeWatchClassification.new(classification)
        estimate = Nero::WildlifeWatch::WildlifeWatchEstimate.new(estimate)
        estimate.add_vote(classification.vote)
        @storage.record_estimate(estimate)

        if estimate.retired?
          @panoptes.retire(estimate)
        end
      end
    end
  end
end
