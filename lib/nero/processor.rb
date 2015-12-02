require_relative 'swap/swap_algorithm'
require_relative 'wildlife_watch/wildlife_watch_algorithm'

module Nero
  class Processor
    include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

    class NullAlgorithm
      def process(*args)
        return []
      end
    end

    ALGORITHMS = {
      'wildlife_watch' => Nero::WildlifeWatch::WildlifeWatchAlgorithm,
      'swap' => Nero::Swap::SwapAlgorithm
    }

    attr_reader :workflows

    def initialize(storage, output, config)
      @storage = storage
      @output  = output
      @workflows = config.each.with_object(Hash.new(NullAlgorithm.new)) do |(workflow_id, workflow_config), hash|
        hash[workflow_id.to_s] = ALGORITHMS.fetch(workflow_config.fetch('algorithm')).new(storage, output)
      end
    end

    def process(data)
      linked_data = data.fetch("linked") { {} }
      data.fetch("classifications").each do |classification_hash|
        classification = Classification.new(classification_hash, linked: linked_data)
        Nero.logger.info "processing", classification_id: classification.id, subject_ids: classification.subject_ids
        agent = @storage.find_agent(classification.user_id)
        estimate = @storage.find_estimate(classification.subject_ids.join("-"), classification.workflow_id)
        workflows[classification.workflow_id.to_s].process(classification, agent, estimate)
      end
    end

    add_transaction_tracer :process, category: :task
  end
end
