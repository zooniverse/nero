require 'date'
require 'set'

module Nero
  module WildlifeWatch
    class WildlifeWatchEstimate < SimpleDelegator
      def votes
        data["votes"] ||= []
        data["votes"]
      end

      def add_vote(vote)
        self.votes << vote
      end

      def retired?
        grouped_votes = votes.group_by { |i| i }
        grouped_votes.default = []

        return :human        if grouped_votes["human"].size >= 1                    # if one classification says it's a human
        return :five_blanks  if grouped_votes["blank"].size >= 5                    # if 5 classifications say the image is blank
        return :consensus    if grouped_votes.any? { |_, group| group.size >= 7 } # if 7 classifications agree
        return :three_blanks if votes[0..2].count("blank") == 3                    # if the first 3 classifications say the image is blank
        false # leaving the 15 classifications limit up to panoptes
      end
    end
  end
end
