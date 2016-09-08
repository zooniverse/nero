module Nero
  module ChicagoWildlifeWatch
    class ChicagoWildlifeWatchClassification < SimpleDelegator
      def vote
        case
        when choices.empty?
          "blank"
        when choices.include?("NTHNGHR")
          "blank"
        when choices.include?("HMN")
          "human"
        when choices.include?("RPRTTHSPHT")
          "reported"
        else
          choices.join("-") # Should only ever be one choice probably
        end
      end

      private

      def annotations
        @annotations ||= hash.fetch("annotations", {}).group_by { |ann| ann["task"] }
      end

      def task
        annotations.fetch("T0").first || {}
      end

      def choices
        values = task.fetch("value", [])
        values.map { |val| val["choice"] }
      end
    end
  end
end
