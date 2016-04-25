require 'date'
require 'set'

module Nero
  module PulsarHunters
    class PulsarHuntersSubjectState < SimpleDelegator
      def add(classification_id)
        data["classification_ids"] ||= []
        data["classification_ids"] << classification_id
      end

      def classifications_count
        data["classification_ids"] ||= []
        data["classification_ids"].size
      end
    end
  end
end
