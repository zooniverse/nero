require 'poseidon'
require 'poseidon_cluster'

module Nero
  module Input
    class KafkaReader
      attr_reader :processor

      def initialize(processor:, group_name:, brokers:, zookeepers:, topic:)
        @processor = processor
        @consumer = Poseidon::ConsumerGroup.new(group_name, brokers, zookeepers, topic,
                                                socket_timeout_ms: 20000, max_wait_ms: 1000)
      end

      # Running the Kafka reader will wait until it processes *at least* one message,
      # and then continue looping until there are no more messages in the Kafka topic.
      # This behaviour is useful in the test suite where we need some way of processing
      # everything in the topic. The first loop is needed to wait until Kafka has started
      # routing messages to partitions, the second is needed so that everything the test
      # suite puts in the topic is actually processed.
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

        ok = @consumer.fetch do |partition, messages|
          id = partition
          messages.each do |message|
            count += 1
            processor.process(JSON.parse(message.value))
          end
        end

        if ok
          return id, count
        else
          Nero.logger.warn "Running more processors than partitions, this one has nothing to do"
          sleep 30 # Manual sleep since we're not waiting on a socket timeout
          return nil, 0
        end
      end
    end
  end
end
