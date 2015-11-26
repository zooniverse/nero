require 'date'
require 'set'

module Nero
  module WildlifeWatch
    class WildlifeWatchEstimate < SimpleDelegator
      def add_vote(vote)
        data["votes"] ||= []
        data["votes"] << vote
        @vote_counts = nil
      end

      def retired?
        return :human        if vote_counts["human"] >= 1                    # if one classification says it's a human
        return :five_blanks  if vote_counts["blank"] >= 5                    # if 5 classifications say the image is blank
        return :consensus    if vote_counts.any? { |_, count| count >= 7 }   # if 7 classifications agree
        return :three_blanks if votes[0..2].count("blank") == 3              # if the first 3 classifications say the image is blank
        false # leaving the 15 classifications limit up to panoptes
      end

      private

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
