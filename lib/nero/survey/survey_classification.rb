module Nero
  module Survey
    class SurveyClassification < SimpleDelegator
      def vote(task_key)
        task_choices = choices(task_key)
        case
        when task_choices.empty?
          "blank"
        when task_choices.include?("NTHNGHR")
          "blank"
        when task_choices.include?("HMN")
          "human"
        when task_choices.include?("HMNNTVHCLS")
          # used by camera catalogue, to make config option soon, but
          # under time pressure since they're eager to relaunch asap.
          "human"
        when (task_choices & %w(VHCL MTRZDVHCL)).any?
          # used by camera catalogue & cmp wildlife cameras,
          # to make config option soon,
          # but under time pressure since they're eager to relaunch asap.
          "vehicle"
        when choices(task_key).include?("RPRTTHSPHT")
          "reported"
        else
          choices(task_key).join("-") # Should only ever be one choice probably
        end
      end

      private

      def annotations
        @annotations ||= hash.fetch("annotations", {}).group_by { |ann| ann["task"] }
      end

      def task(task_key)
        annotations.fetch(task_key).first || {}
      end

      def choices(task_key)
        values = task(task_key).fetch("value", [])
        values.map { |val| val["choice"] }
      end
    end
  end
end
