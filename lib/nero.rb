require 'yaml'

module Nero
  def self.load_config(filename, environment)
    path = File.expand_path(File.join('..', '..', 'config', filename), __FILE__)
    YAML.load_file(path).fetch(environment.to_s)
  end
end

require 'sequel'
DB = Sequel.connect(Nero.load_config('database.yml', ENV["RAILS_ENV"]))

require_relative 'nero/input/io_reader'
require_relative 'nero/input/kafka_reader'

require_relative 'nero/storage'

require_relative 'nero/output/io_writer'

require_relative 'nero/agent'
require_relative 'nero/classification'
require_relative 'nero/estimate'
require_relative 'nero/subject'

require_relative 'nero/swap_algorithm'
require_relative 'nero/processor'

module Nero
  def self.start(environment)
    storage = Nero::Storage.new(DB)
    output  = Nero::Output::IOWriter.new(STDOUT)

    processor = Nero::Processor.new(storage, output, load_config('projects.yml', environment))

    kafka_config = load_config('kafka.yml', environment)
    input   = Nero::Input::KafkaReader.new(processor:  processor,
                                                     zookeepers: kafka_config.fetch('zookeepers'),
                                                     group_name: kafka_config.fetch('consumer_group'),
                                                     brokers:    kafka_config.fetch('brokers'),
                                                     topic:      kafka_config.fetch('topic'))

    input
  end
end
