require_relative 'chicago_wildlife_watch/chicago_wildlife_watch_algorithm'
require_relative 'equador/equador_algorithm'
require_relative 'pulsar_hunters/pulsar_hunters_algorithm'
require_relative 'snapshot_wisconsin/snapshot_wisconsin_algorithm'
require_relative 'survey/survey_algorithm'
require_relative 'swap/swap_algorithm'
require_relative 'transcribe_hack/transcribe_hack_algorithm'
require_relative 'blank/blank_algorithm'

module Nero
  class Processor
    include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

    ALGORITHMS = {
      'chicago_wildlife_watch' => Nero::ChicagoWildlifeWatch::ChicagoWildlifeWatchAlgorithm,
      'equador' => Nero::Equador::EquadorAlgorithm,
      'pulsar_hunters' => Nero::PulsarHunters::PulsarHuntersAlgorithm,
      'snapshot_wisconsin' => Nero::SnapshotWisconsin::SnapshotWisconsinAlgorithm,
      'survey' => Nero::Survey::SurveyAlgorithm,
      'swap' => Nero::Swap::SwapAlgorithm,
      'wildlife_watch' => Nero::SnapshotWisconsin::SnapshotWisconsinAlgorithm, # DEPRECATED ALGORITHM KEY, REMOVE IF NO LONGER MENTIONED IN PROJECTS.YML
      'transcribe_hack' => Nero::TranscribeHack::TranscribeHackAlgorithm,
      'blank' => Nero::Blank::BlankAlgorithm,
    }

    attr_reader :workflow_repo, :subject_repo, :classification_repo
    attr_reader :workflows

    def initialize(storage, output, config)
      @storage = storage
      @output  = output
      @workflow_repo = Repositories::WorkflowRepository.new(storage.db)
      @subject_repo = Repositories::SubjectRepository.new(storage.db)
      @classification_repo = Repositories::ClassificationRepository.new(storage.db)

      @workflows = config.each.with_object(Hash.new(Algorithm.new(@storage, @output))) do |(workflow_id, workflow_config), hash|
        hash[workflow_id.to_s] = ALGORITHMS.fetch(workflow_config.fetch('algorithm')).new(storage, output, workflow_config)
      end
    end

    def process(record)
      old_style_processing(record)
      new_style_processing(record)
    end

    def old_style_processing(record)
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

    def new_style_processing(record)
      return unless process?(record)

      workflow_repo.update_caches(record.fetch("linked").fetch("workflows"))
      subject_repo.update_caches(record.fetch("linked").fetch("subjects"))
      id = classification_repo.update_cache(record.fetch("data"))

      ClassificationProcessing.new(id).perform
    end

    def process?(record)
      return false unless record["linked"]
      return false unless record["linked"]["workflows"]
      return false unless record["linked"]["workflows"].any? { |workflow| workflow["retirement"] }

      true
    end

    add_transaction_tracer :process, category: :task
  end
end
