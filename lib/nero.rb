require 'yaml'
require 'logger'
require 'newrelic_rpm'
require 'honeybadger'
require 'sequel'
require 'poseidon'

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
    Poseidon.logger = Nero.logger
    logger
  end
end

Nero.logger
DB = Sequel.connect(Nero.load_config('database.yml', ENV["RAILS_ENV"]))
NewRelic::Agent.manual_start
Honeybadger.start(:'config.path' => Nero.config_path("honeybadger.yml"))

require_relative 'nero/input/io_reader'
require_relative 'nero/input/kafka_reader'
require_relative 'nero/storage'
require_relative 'nero/output/io_writer'
require_relative 'nero/agent'
require_relative 'nero/classification'
require_relative 'nero/estimate'
require_relative 'nero/subject'
require_relative 'nero/processor'

module Nero
  def self.start(environment)
    storage = Nero::Storage.new(DB)
    output  = Nero::Output::IOWriter.new(STDOUT)

    processor = Nero::Processor.new(storage, output, load_config('projects.yml', environment))

    kafka_config = load_config('kafka.yml', environment)
    input = Nero::Input::KafkaReader.new(processor:  processor,
                                         zookeepers: kafka_config.fetch('zookeepers'),
                                         group_name: kafka_config.fetch('consumer_group'),
                                         brokers:    kafka_config.fetch('brokers'),
                                         topic:      kafka_config.fetch('topic'))

    input
  rescue StandardError => exception
    Honeybadger.notify(exception)
    raise
  end
end
