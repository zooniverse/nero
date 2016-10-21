require 'date'
require 'set'

module Nero
  module Survey
    class SurveySubjectState < SimpleDelegator
      def add_vote(id, vote)
        data["results"] ||= []
        data["results"] << {"id" => id, "vote" => vote}
        @vote_counts = nil
      end

      def results
        data["results"] ||= []
        data["results"]
      end
    end
  end
end
