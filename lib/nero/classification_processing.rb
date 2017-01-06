module Nero
  class ClassificationProcessing
    attr_reader :repositories, :classification_id

    def initialize(repositories, classification_id)
      @repositories = repositories
      @classification_id = classification_id
    end

    def perform
      essences = extractors.each do |extractor|
        essence = extractor.process(classification)
      end

      reductions = reducers.each do |reducer|
        reducer.process(essences)
      end

      reduction = reductions.reduce({}) { |memo, obj| memo.merge(obj) }

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
      @classification ||= repositories[:classifications].find(classification_id)
    end

    def workflow
      @workflow ||= repositories[:workflows].find(classification.workflow_id)
    end

    def subject
      @subject ||= repositories[:subjects].find(classification.subject_id)
    end
  end
end
