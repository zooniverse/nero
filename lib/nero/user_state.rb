module Nero
  class UserState
    attr_reader :id, :external_id, :data

    def initialize(id:, external_id:, data: {})
      @id = id
      @external_id = external_id
      @data = data
    end

    def attributes
      {
        external_id: external_id,
        data: data,
      }
    end
  end
end
