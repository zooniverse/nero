require 'yaml'

module RetirementSwap
  def self.load_config(filename, environment)
    path = File.expand_path(File.join('..', '..', 'config', filename), __FILE__)
    YAML.load_file(path).fetch(environment.to_s)
  end
end

require 'sequel'
DB = Sequel.connect(RetirementSwap.load_config('database.yml', ENV["RAILS_ENV"]))

require_relative 'retirement_swap/input/io_reader'
require_relative 'retirement_swap/input/kafka_reader'

require_relative 'retirement_swap/storage'

require_relative 'retirement_swap/output/io_writer'

require_relative 'retirement_swap/agent'
require_relative 'retirement_swap/classification'
require_relative 'retirement_swap/estimate'
require_relative 'retirement_swap/subject'

require_relative 'retirement_swap/swap_algorithm'
require_relative 'retirement_swap/processor'

module RetirementSwap
  def self.start(environment)
    storage = RetirementSwap::Storage.new(DB)
    output  = RetirementSwap::Output::IOWriter.new(STDOUT)

    processor = RetirementSwap::Processor.new(storage, output, load_config('projects.yml', environment))

    kafka_config = load_config('kafka.yml', environment)
    input   = RetirementSwap::Input::KafkaReader.new(processor:  processor,
                                                     zookeepers: kafka_config.fetch('zookeepers'),
                                                     group_name: kafka_config.fetch('consumer_group'),
                                                     brokers:    kafka_config.fetch('brokers'),
                                                     topic:      kafka_config.fetch('topic'))

    input
  end
end
