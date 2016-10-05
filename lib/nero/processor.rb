require_relative 'swap/swap_algorithm'
require_relative 'chicago_wildlife_watch/chicago_wildlife_watch_algorithm'
require_relative 'equador/equador_algorithm'
require_relative 'pulsar_hunters/pulsar_hunters_algorithm'
require_relative 'snapshot_wisconsin/snapshot_wisconsin_algorithm'
require_relative 'transcribe_hack/transcribe_hack_algorithm'

module Nero
  class Processor
    include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

    ALGORITHMS = {
      'chicago_wildlife_watch' => Nero::ChicagoWildlifeWatch::ChicagoWildlifeWatchAlgorithm,
      'equador' => Nero::Equador::EquadorAlgorithm,
      'pulsar_hunters' => Nero::PulsarHunters::PulsarHuntersAlgorithm,
      'snapshot_wisconsin' => Nero::SnapshotWisconsin::SnapshotWisconsinAlgorithm,
      'swap' => Nero::Swap::SwapAlgorithm,
      'wildlife_watch' => Nero::SnapshotWisconsin::SnapshotWisconsinAlgorithm, # DEPRECATED ALGORITHM KEY, REMOVE IF NO LONGER MENTIONED IN PROJECTS.YML
      'transcribe_hack' => Nero::TranscribeHack::TranscribeHackAlgorithm
    }

    attr_reader :workflows

    def initialize(storage, output, config)
      @storage = storage
      @output  = output
      @workflows = config.each.with_object(Hash.new(Algorithm.new(@storage, @output))) do |(workflow_id, workflow_config), hash|
        hash[workflow_id.to_s] = ALGORITHMS.fetch(workflow_config.fetch('algorithm')).new(storage, output, workflow_config)
      end
    end

    def process(record)
      linked_data         = record.fetch("linked") { {} }
      classification_hash = record.fetch("data")
      classification      = Classification.new(classification_hash, linked: linked_data)

      Nero.logger.info "processing", classification_id: classification.id, subject_ids: classification.subject_ids

      user_state = @storage.find_user_state(classification.user_id)
      subject_state = @storage.find_subject_state(classification.subject_ids.join("-"), classification.workflow_id)

      begin
        workflows[classification.workflow_id.to_s].process(classification, user_state, subject_state)
      rescue StandardError => exception
        Honeybadger.notify(exception, context: {classification_id: classification.id, subject_ids: classification.subject_ids})
        Nero.logger.error 'processing-failed', classification_id: classification.id, subject_ids: classification.subject_ids
      end
    end

    add_transaction_tracer :process, category: :task
  end
end
