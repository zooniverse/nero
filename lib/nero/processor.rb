module Nero
  class Processor
    class NullAlgorithm
      def process(*args)
        return []
      end
    end

    ALGORITHMS = {
      'swap' => Nero::SwapAlgorithm
    }

    attr_reader :workflows

    def initialize(storage, output, config)
      @storage = storage
      @output  = output
      @workflows = config.each.with_object(Hash.new(NullAlgorithm.new)) do |(workflow_id, workflow_config), hash|
        hash[workflow_id] = ALGORITHMS.fetch(workflow_config.fetch('algorithm')).new(storage, output)
      end
    end

    def process(hash)
      classification = Classification.new(hash)
      agent = @storage.find_agent(classification.user_id)
      estimate = @storage.find_estimate(classification.subject_ids.join("-"), classification.workflow_id)
      workflows[classification.workflow_id].process(classification, agent, estimate)
    end
  end
end
