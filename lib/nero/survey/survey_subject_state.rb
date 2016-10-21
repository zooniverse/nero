require 'date'
require 'set'

module Nero
  module Survey
    class SurveySubjectState < SimpleDelegator
      def add_vote(vote)
        data["votes"] ||= []
        data["votes"] << vote
        @vote_counts = nil
      end

      def votes
        data["votes"] ||= []
        data["votes"]
      end

      def vote_counts
        @vote_counts ||= votes.reduce(Hash.new(0)) do |groups, vote|
          groups[vote] += 1
          groups
        end
      end
    end
  end
end
