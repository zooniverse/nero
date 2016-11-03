module Nero
  module Blank
    class BlankSubjectState < SimpleDelegator
      def add_vote(classification_id, vote)
        data["votes"] ||= []
        data["votes"] << {"classification_id" => classification_id, "value" => vote}
      end

      def retired?(blank_consensus_limit)
        if votes.count { |vote| vote["value"] == "blank" } >= blank_consensus_limit
          :blank_consensus
        else
          false
        end
      end

      private

      def votes
        data["votes"] ||= {}
        data["votes"]
      end
    end
  end
end
