module Nero
  class Classification
    attr_reader :hash, :linked

    def initialize(hash, linked: {})
      @hash = hash
      @linked = linked
    end

    def flagged?
      hash.fetch("metadata", {}).fetch("subject_flagged", false)
    end

    def id
      hash.fetch("id")
    end

    def subjects
      @subjects ||= subject_ids.map do |subject_id|
        attributes = linked.fetch("subjects", {}).find do |subject_data|
          subject_data.fetch("id") == subject_id
        end

        Subject.new(subject_id, attributes)
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
