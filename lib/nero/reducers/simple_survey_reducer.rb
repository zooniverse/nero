module Nero
  module Reducers
    class SimpleSurveyReducer
      attr_reader :sub_ranges

      def initialize(sub_ranges: [{from: 0, till: 3}])
        @sub_ranges = sub_ranges
      end

      def process(extractions)
        results = {}

        sub_ranges.each do |range|
          from = range.fetch(:from)
          till = range.fetch(:till)

          extractions[from..till].each do |extraction|
            extraction.fetch("choices").each do |choice|
              increment(results, "survey-from#{from}to#{till}-#{choice}")
            end
          end
        end

        extractions.each do |extraction|
          extraction.fetch("choices").each do |choice|
            increment(results, "survey-total-#{choice}")
          end
        end

        results
      end

      private

      def increment(results, key)
        results[key] ||= 0
        results[key] += 1
      end
    end
  end
end
