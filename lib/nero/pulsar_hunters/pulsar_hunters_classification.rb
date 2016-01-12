require_relative 'pulsar_hunters_subject'

module Nero
  module PulsarHunters
    class PulsarHuntersClassification < SimpleDelegator
      def subjects
        super.map { |subject| PulsarHuntersSubject.new(subject) }
      end
    end
  end
end
