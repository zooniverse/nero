module Nero
  module WildlifeWatch
    class WildlifeWatchClassification < SimpleDelegator
      def vote
        case
        when init_task["value"] == 0
          "blank"
        when init_task["value"] == 1
          "human"
        when choices.include?("HMN")
          "human"
        else
          "animal"
        end
      end

      private

      def annotations
        @annotations ||= hash.fetch("annotations", {}).group_by { |ann| ann["task"] }
      end

      def init_task
        (annotations.fetch("init") || [])[0] || {}
      end

      def t1_task
        (annotations.fetch("T1") || [])[0] || {}
      end

      def choices
        values = t1_task["value"] || []
        values.map { |val| val["choice"] }
      end
    end
  end
end
