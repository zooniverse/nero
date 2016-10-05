module Nero
  module TranscribeHack
    class TranscribeHackClassification < SimpleDelegator
      def vote
      end

      private

      def annotations
        @annotations ||= hash.fetch("annotations", {}).group_by { |ann| ann["task"] }
      end

      def task
        annotations.fetch("init").first
      end

      def anything_here?
        task.fetch("value") != 1
      end
    end
  end
end
