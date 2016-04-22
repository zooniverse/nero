require_relative 'swap/swap_algorithm'
require_relative 'wildlife_watch/wildlife_watch_algorithm'
require_relative 'pulsar_hunters/pulsar_hunters_algorithm'

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
      'swap' => Nero::Swap::SwapAlgorithm,
      'pulsar_hunters' => Nero::PulsarHunters::PulsarHuntersAlgorithm
    }

    attr_reader :workflows

    def initialize(storage, output, config)
      @storage = storage
      @output  = output
      @workflows = config.each.with_object(Hash.new(NullAlgorithm.new)) do |(workflow_id, workflow_config), hash|
        hash[workflow_id.to_s] = ALGORITHMS.fetch(workflow_config.fetch('algorithm')).new(storage, output, workflow_config)
      end
    end

    def process(record)
      linked_data         = record.fetch("linked") { {} }
      classification_hash = record.fetch("data")
      classification      = Classification.new(classification_hash, linked: linked_data)

      Nero.logger.info "processing", classification_id: classification.id, subject_ids: classification.subject_ids

      user_state = @storage.find_user_state(classification.user_id)
      estimate = @storage.find_estimate(classification.subject_ids.join("-"), classification.workflow_id)

      begin
        workflows[classification.workflow_id.to_s].process(classification, user_state, estimate)
      rescue StandardError => exception
        Honeybadger.notify(exception, context: {classification_id: classification.id, subject_ids: classification.subject_ids})
        Nero.logger.error 'processing-failed', classification_id: classification.id, subject_ids: classification.subject_ids
      end
    end

    add_transaction_tracer :process, category: :task
  end
end
