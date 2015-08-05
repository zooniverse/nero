module RetirementSwap
  class Subject
    attr_reader :id, :attributes, :category, :kind

    def initialize(id, attributes)
      @id = id
      @attributes = attributes
      @category = 'test'
      @kind = 'test'

      training = attributes["metadata"]["training"]
      if training && training.count > 0 && training.first["type"]
        if ["lensing cluster", "lensed quasar", "lensed galaxy"].include? training.first["type"]
          @category = 'training'
          @kind     = 'sim'
        elsif  training.first["type"] == "empty"
          @category = 'training'
          @kind     = 'dud'
        end
      end
    end

    def test?
      category == 'test'
    end

    def training?
      category == "training"
    end

    def sim?
      kind == 'sim'
    end
  end
end
