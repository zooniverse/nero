module Nero
  module Spacewarps
    class SpacewarpsClassification < SimpleDelegator

      def subjects
        super.map { |subject| SpacewarpsSubject.new(subject) }
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

      def markers
        hash["annotations"].select   { |ann| ann["task"] == "T1" }
                           .flat_map { |ann| ann["value"] }
      end

      def markers?
        markers.select { |value| value["tool"] == 0 }.size > 0
      end

      def sim_found?
        sims_found = hash["annotations"].select { |a| a.keys.include? "simFound" }
        sims_found.first && sims_found.first["simFound"] == "true"
      end
    end
  end
end
