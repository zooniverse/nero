module Nero
  module PulsarHunters
    class PulsarHuntersSubject < SimpleDelegator
      def gold_standard?
        case attributes.fetch("metadata")['#Class'].to_s.downcase
        when "known", "disc", "fake"
          true
        else
          false
        end
      end
    end
  end
end
