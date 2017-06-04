module Nero
  class SubjectState
    attr_reader :id, :subject_id, :workflow_id, :data

    def initialize(id:, subject_id:, workflow_id:, data: {})
      @id = id
      @subject_id = subject_id
      @workflow_id = workflow_id
      @data = data || {}
    end

    def attributes
      {
        subject_id: subject_id,
        workflow_id: workflow_id,
        data: data
      }
    end

    def to_json(*_args)
      JSON.dump(attributes)
    end
  end
end
