module Nero
  module Reducers
    class SimpleSurveyReducer
      attr_reader :sub_ranges

      def initialize(sub_ranges: [{from: 0, till: 2}])
        @sub_ranges = sub_ranges
      end

      def process(extractions)
        results = {}

        process_range(results, extractions, "survey-total")

        sub_ranges.each do |range|
          from = range.fetch(:from)
          till = range.fetch(:till)
          process_range(results, extractions[from..till], "survey-from#{from}to#{till}")
        end

        results
      end

      private

      def process_range(results, extractions, key_prefix)
        extractions.each do |extraction|
          extraction.fetch("choices").each do |choice|
            increment(results, "#{key_prefix}-#{choice}")
          end
        end
      end

      def increment(results, key)
        results[key] ||= 0
        results[key] += 1
      end
    end
  end
end
