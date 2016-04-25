require 'date'
require 'set'

module Nero
  module Equador
    class EquadorSubjectState < SimpleDelegator
      def add_vote(classification_id, vote)
        data["votes"] ||= []
        data["votes"] << {"classification_id" => classification_id, "value" => vote}
      end

      def retired?
        # retire if any of the first three classifications say it's blank
        return :three_blanks if votes[0..4].count { |vote| vote["value"] == "blank" } >= 3

        # otherwise just leave it up to panoptes
        false
      end

      private

      def votes
        data["votes"] ||= {}
        data["votes"]
      end
    end
  end
end
