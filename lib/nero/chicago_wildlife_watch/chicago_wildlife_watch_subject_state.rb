require 'date'
require 'set'

module Nero
  module ChicagoWildlifeWatch
    class ChicagoWildlifeWatchSubjectState < SimpleDelegator
      def add_vote(vote)
        data["votes"] ||= []
        data["votes"] << vote
        @vote_counts = nil
      end

      def retired?
        return :consensus    if vote_counts.any? { |_, count| count >= 7 } # If 7 users have annotated the same animal, retire it.
        return :human        if vote_counts["human"] >= 1                  # If anyone has annotated a human, retire it.
        return :flagged      if vote_counts["reported"] >= 1               # If anyone has annotated the subject as ‘Report this photo’, retire it.
        return :three_blanks if votes[0..2].count("blank") == 3            # If the first three users annotated the subject as blank, retire it.
        return :five_blanks  if vote_counts["blank"] >= 5                  # If 5 users annotated the subject as blank, retire it.
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
