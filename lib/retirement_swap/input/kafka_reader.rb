require 'poseidon'
require 'poseidon_cluster'

module RetirementSwap
  module Input
    class KafkaReader
      attr_reader :processor

      def initialize(processor:, group_name:, brokers:, zookeepers:, topic:)
        @processor = processor
        @consumer = Poseidon::ConsumerGroup.new(group_name, brokers, zookeepers, topic,
                                                socket_timeout_ms: 20000, max_wait_ms: 1000)
      end

      def run
        counts = Hash.new(0)
        begin
          partition, count = process_a_partition
          counts[partition] = count
        end until counts.any? {|partition, count| count > 0 }

        begin
          partition, count = process_a_partition
          counts[partition] = count
        end while counts.any? {|partition, count| count > 0 }
      end

      private

      def process_a_partition
        count = 0
        id = nil

        @consumer.fetch do |partition, messages|
          id = partition
          messages.each do |message|
            count += 1
            processor.process(JSON.parse(message.value))
          end
        end

        return id, count
      end
    end
  end
end
