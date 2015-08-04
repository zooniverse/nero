module RetirementSwap
  class Classification
    attr_reader :hash

    def initialize(hash)
      @hash = hash
    end

    def subjects
      hash.fetch("subjects", {}).map do |id, attributes|
        Subject.new(id, attributes)
      end
    end

    def user_id
      hash.fetch("links").fetch("user")
    end

    def workflow_id
      hash.fetch("links").fetch("workflow")
    end

    def subject_ids
      hash.fetch("links").fetch("subjects")
    end

    def guess
      if subjects.first.training?
        training_guess
      else
        test_guess
      end
    end

    def training_guess
      case subjects.first.kind
      when 'sim'
        if sim_found?
          "LENS"
        else
          "NOT"
        end
      when 'dud'
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
