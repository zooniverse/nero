module Nero
  class Algorithm
    attr_reader :storage, :panoptes, :options

    def initialize(storage, panoptes, options = {})
      @storage = storage
      @panoptes = panoptes
      @options = options
    end
    
    def process(classification, user_state, subject_state )
      if classification.flagged?
        panoptes.retire(subject_state)
      end

      return []
    end
  end
end
