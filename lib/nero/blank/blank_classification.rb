module Nero
  module Blank
    class BlankClassification < SimpleDelegator
      def vote(task_key)
        if empty_annotation?(task_key)
          "blank"
        else
          "something"
        end
      end

      private

      def annotations
        @annotations ||= hash.fetch("annotations", {}).group_by { |ann| ann["task"] }
      end

      def task(task_key)
        annotations.fetch(task_key).first
      end

      def empty_annotation?(task_key)
        task(task_key).fetch("value").empty?
      end
    end
  end
end
