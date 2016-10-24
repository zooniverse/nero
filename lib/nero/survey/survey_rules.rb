module Nero
  module Survey
    class SurveyRules
      attr_reader :options

      def initialize(options)
        @options = options
      end

      def apply_to(results)
        vote_counts = group_results(results)

        return :consensus       if vote_counts.any? { |_, count| count >= consensus_limit }
        return :human           if vote_counts["human"] >= human_limit
        return :flagged         if vote_counts["reported"] >= flagged_limit
        return :blank           if votes(results).first(blank_limit).count("blank") == blank_limit
        return :blank_consensus if vote_counts["blank"] >= blank_consensus_limit
        false
      end

      def votes(results)
        results.map {|result| result["vote"] }
      end

      def group_results(results)
        votes(results).reduce(Hash.new(0)) do |groups, vote|
          groups[vote] += 1
          groups
        end
      end

      def task_key
        options.fetch(:task_key, "T0")
      end

      def consensus_limit
        options.fetch(:consensus_limit, 7)
      end

      def human_limit
        options.fetch(:human_limit, 1)
      end

      def flagged_limit
        options.fetch(:flagged_limit, 1)
      end

      def blank_limit
        options.fetch(:blank_limit, 3)
      end

      def blank_consensus_limit
        options.fetch(:blank_consensus_limit, 5)
      end
    end
  end
end
