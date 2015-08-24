module Nero
  class Subject
    attr_reader :id, :attributes, :category, :kind

    def initialize(id, attributes)
      @id = id
      @attributes = attributes
    end
  end
end
