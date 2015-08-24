module Nero
  module Swap
    class SwapClassification < SimpleDelegator

      def subjects
        super.map { |subject| SwapSubject.new(subject) }
      end

      def guess
        if subjects.first.training?
          training_guess
        else
          test_guess
        end
      end

      def training_guess
        if subjects.first.sim?
          if sim_found?
            "LENS"
          else
            "NOT"
          end
        else
          test_guess
        end
      end

      def test_guess
        if markers?
          "LENS"
        else
          "NOT"
        end
      end

      def markers?
        hash["annotations"].select{ |annotation| annotation.keys.include? "x" }.count > 0
      end

      def sim_found?
        sims_found = hash["annotations"].select { |a| a.keys.include? "simFound" }
        sims_found.first && sims_found.first["simFound"] == "true"
      end
    end
  end
end
