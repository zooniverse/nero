module Nero
  module Equador
    class EquadorClassification < SimpleDelegator
      def vote
        if anything_here?
          "something"
        else
          "blank"
        end
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
