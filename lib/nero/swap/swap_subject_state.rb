require 'date'
require 'set'

module Nero
  module Swap
    class SwapSubjectState < SimpleDelegator
      INITIAL_PRIOR = 2e-4
      REJECTION_THRESHOLD = 1e-07
      DETECTION_THRESHOLD = 0.95

      def adjust(user_state, guess)
        pl = user_state.pl
        pd = user_state.pd

        if guess=="LENS"
          likelihood = pl
          likelihood /= (pl*probability + (1-pd)*(1-probability))
        else
          likelihood = (1-pl)
          likelihood /= ((1-pl)*probability + pd*(1-probability))
        end

        guesses << {"timestamp" => DateTime.now.strftime("%Q"), "user_id" => user_state.external_id, "answer" => guess, "probability" => likelihood * probability}
        self
      end

      def guesses
        data["guesses"] ||= []
      end

      def probability
        (guesses.last && guesses.last["probability"]) || INITIAL_PRIOR
      end

      def status
        case
        when rejected?
          :rejected
        when detected?
          :detected
        else
          :active
        end
      end

      def active?
        status == :active
      end

      def retired?
        status != :active
      end

      def seen_by?(user_ids)
        user_ids = Set.new(user_ids)

        guesses.any? do |guess|
          user_ids.include?(guess["user_id"])
        end
      end

      private

      def rejected?
        probability < REJECTION_THRESHOLD
      end

      def detected?
        probability > DETECTION_THRESHOLD
      end
    end
  end
end
