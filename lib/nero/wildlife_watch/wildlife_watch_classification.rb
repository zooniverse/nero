module Nero
  module WildlifeWatch
    class WildlifeWatchClassification < SimpleDelegator
      def vote
        case
        when choices.empty?
          "blank"
        when choices.include?("NTHNGHR")
          "blank"
        when choices.include?("HMN")
          "human"
        else
          choices.join("-") # Should only ever be one choice probably
        end
      end

      private

      def annotations
        @annotations ||= hash.fetch("annotations", {}).group_by { |ann| ann["task"] }
      end

      def task
        case workflow_id
        when "1021"
          annotations.fetch("T1", []).first || {}
        when "1590"
          annotations.fetch("T0").first || {}
        else
          raise "not tested against this workflow yet, check question key"
        end
      end

      def choices
        values = task.fetch("value", [])
        values.map { |val| val["choice"] }
      end
    end
  end
end
