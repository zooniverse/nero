require_relative 'retirement_swap/input/io_reader'
require_relative 'retirement_swap/input/kafka_reader'

require_relative 'retirement_swap/storage/memory'
require_relative 'retirement_swap/storage/database'

require_relative 'retirement_swap/output/io_writer'

require_relative 'retirement_swap/agent'
require_relative 'retirement_swap/classification'
require_relative 'retirement_swap/estimate'
require_relative 'retirement_swap/subject'

require_relative 'retirement_swap/swap_algorithm'

module RetirementSwap
  def self.start(environment)
    database_config = YAML.load_file(File.expand_path('../../config/database.yml', __FILE__)).fetch(environment.to_s)
    db = Sequel.connect(database_config)

    storage = RetirementSwap::Storage::Database.new(db)
    output  = RetirementSwap::Output::IOWriter.new(STDOUT)
    swap    = RetirementSwap::SwapAlgorithm.new(storage, output)

    kafka_config = YAML.load_file(File.expand_path('../../config/kafka.yml', __FILE__)).fetch(environment.to_s)
    input   = RetirementSwap::Input::KafkaReader.new(processor:  swap,
                                                     zookeepers: kafka_config.fetch('zookeepers'),
                                                     group_name: kafka_config.fetch('consumer_group'),
                                                     brokers:    kafka_config.fetch('brokers'),
                                                     topic:      kafka_config.fetch('topic'))

    input
  end
end
