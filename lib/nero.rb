require 'yaml'
require 'logger'
require 'newrelic_rpm'
require 'honeybadger'
require 'sequel'
require 'telekinesis'
require 'dotenv'

module Nero
  class NullLogger
    def fatal(*args); end
    def error(*args); end
    def warn(*args); end
    def info(*args); end
    def debug(*args); end
  end

  class LoggerLogger
    def initialize(logger)
      @logger = logger
    end

    def fatal(message = nil, metadata = {})
      @logger.fatal("#{message || yield} #{JSON.dump(metadata)}")
    end

    def error(message = nil, metadata = {})
      @logger.error("#{message || yield} #{JSON.dump(metadata)}")
    end

    def warn(message = nil, metadata = {})
      @logger.warn("#{message || yield} #{JSON.dump(metadata)}")
    end

    def info(message = nil, metadata = {})
      @logger.info("#{message || yield} #{JSON.dump(metadata)}")
    end

    def debug(message = nil, metadata = {})
      @logger.debug("#{message || yield} #{JSON.dump(metadata)}")
    end
  end

  def self.config_path(filename)
    File.expand_path(File.join('..', '..', 'config', filename), __FILE__)
  end

  def self.load_config(filename, environment)
    path = config_path(filename)
    YAML.load_file(path).fetch(environment.to_s)
  end

  def self.logger
    return @logger if @logger
    self.logger = LoggerLogger.new(Logger.new(STDOUT))
  end

  def self.logger=(logger)
    @logger = logger
    logger
  end
end

Nero.logger
Dotenv.load
NewRelic::Agent.manual_start
Honeybadger.start(:'config.path' => Nero.config_path("honeybadger.yml"))

DB = Sequel.connect(Nero.load_config('database.yml', ENV.fetch("RAILS_ENV")))
DB.extension :pg_json

require_relative 'nero/input/io_reader'
require_relative 'nero/storage'
require_relative 'nero/output/io_writer'
require_relative 'nero/output/panoptes_api'
require_relative 'nero/agent'
require_relative 'nero/classification'
require_relative 'nero/estimate'
require_relative 'nero/subject'
require_relative 'nero/algorithm'
require_relative 'nero/processor'

module Nero
  def self.start(environment)
    storage = Nero::Storage.new(DB)

    panoptes_config = load_config('panoptes.yml', environment)
    output = Nero::Output::PanoptesApi.new(panoptes_config.fetch("url"),
                                           panoptes_config.fetch("client_id"),
                                           panoptes_config.fetch("client_secret"))

    processor = Nero::Processor.new(storage, output, load_config('projects.yml', environment))

    input = Telekinesis::Consumer::KCL.new(stream: ENV.fetch("AWS_KINESIS_STREAM", "panoptes-staging"),
                                           app:    ENV.fetch("AWS_KINESIS_APPNAME", "nero-development")) do
      Telekinesis::Consumer::Block.new do |records, checkpointer, millis_behind|
        records.each do |record|
          begin
            json = String.from_java_bytes(record.data.array)
            hash = JSON.parse(json)
            puts ">>> #{hash.inspect}"

            if hash.fetch("source") == "panoptes" && hash.fetch("type") == "classification"
              processor.process(hash)
            elsif hash.fetch("source") == "talk" && hash.fetch("type") == "comment"
              # reserved for future processing (e.g. MICO)
            end
          rescue StandardError => ex
            Honeybadger.notify(ex)
          end
        end

        checkpointer.checkpoint
      end
    end

    input
  rescue StandardError => exception
    Honeybadger.notify(exception)
    raise
  end
end
