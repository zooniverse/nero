require 'poseidon'

module RetirementSwap
  module Input
    class KafkaReader
      attr_reader :processor

      def initialize(processor:, brokers:, topics:, consumer_id:)
        @processor = processor

        @broker = Poseidon::BrokerPool.new(consumer_id, brokers, 1000)
        @consumers = []
        @cluster_metadata = Poseidon::ClusterMetadata.new
        setup_topic_partition_consumers(brokers, topics, consumer_id)
      end

      def run
        @consumers.each do |consumer|
          puts 'attempting to fetch message from partition consumer'
          messages = consumer.fetch
          messages.each do |message|
            processor.process(JSON.parse(message.value))
          end
          sleep 1
        end
      end

      private

      def topic_partition_count(topic)
        @cluster_metadata.update(@broker.fetch_metadata([topic]))
        @cluster_metadata.topic_metadata[topic].partition_count
      end

      def lead_broker_for_topic_parition(topic, partition)
        @cluster_metadata.lead_broker_for_partition(topic, partition)
      end

      def setup_topic_partition_consumers(brokers, topics, consumer_id)
        topics.each do |topic|
          topic_partition_count(topic).times do |partition_count|
            consumer_opts = [consumer_id, brokers, topic, partition_count, :earliest_offset]
            @consumers << Poseidon::PartitionConsumer.consumer_for_partition(*consumer_opts)
          end
        end
      end
    end
  end
end
