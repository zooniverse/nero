module Nero
  class ClassificationProcessing
    def initialize(classification_id)
      @classification_id = classification_id
    end

    def perform
      extractors.each do |extractor|
        essence = extractor.process(classification)
      end

      reducers.each do |reducer|
        reducer.process(essences)
      end

      rules.each do |rule|
        rule.apply(reduction)
      end
    end

    private

    def extractors
      []
    end

    def reducers
      []
    end

    def rules
      []
    end

    def classification
      nil
    end
  end
end
