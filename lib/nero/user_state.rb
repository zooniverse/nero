module Nero
  class UserState
    attr_reader :id, :user_id, :workflow_id, :data

    def initialize(id:, user_id:, workflow_id:, data: {})
      @id = id
      @user_id = user_id
      @workflow_id = workflow_id
      @data = data || {}
    end

    def attributes
      {
        user_id: user_id,
        workflow_id: workflow_id,
        data: data,
      }
    end

    def to_json(*_args)
      JSON.dump(attributes)
    end
  end
end
