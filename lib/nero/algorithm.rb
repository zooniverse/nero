module Nero
  class Algorithm
    attr_reader :storage, :panoptes, :options

    def initialize(storage, panoptes, options = {})
      @storage = storage
      @panoptes = panoptes
      @options = options
    end

    def process(classification, _user_state, subject_state)
      if classification.user_id && classification.flagged?
        panoptes.retire(subject_state)
      end
    end
  end
end
