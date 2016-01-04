module Nero
  module WildlifeWatch
    class WildlifeWatchClassification < SimpleDelegator
      def vote
        case
        when init_task["value"] == 0
          "blank"
        when init_task["value"] == 1
          "human"
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

      def init_task
        annotations.fetch("init", []).first || {}
      end

      def t1_task
        annotations.fetch("T1", []).first || {}
      end

      def choices
        values = t1_task.fetch("value", [])
        values.map { |val| val["choice"] }
      end
    end
  end
end
