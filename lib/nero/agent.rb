module Nero
  class Agent
    INITIAL_PL = 0.5
    INITIAL_PD = 0.5

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
