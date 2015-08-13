module Nero
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
  end
end
