require 'date'
require 'set'

module Nero
  module TranscribeHack
    class TranscribeHackSubjectState < SimpleDelegator
      def add_vote(classification_id, vote)
        data["votes"] ||= []
        data["votes"] << {"classification_id" => classification_id, "value" => vote}
      end

      def retired?
        data["votes"].size >= 2
      end

      private

      def votes
        data["votes"] ||= {}
        data["votes"]
      end
    end
  end
end
