require 'spec_helper'

describe 'Golden masters' do
  let(:storage) { Nero::Storage.new(DB) }
  let(:output) { Nero::Output::IOWriter.new(StringIO.new) }
  let(:processor) { Nero::Processor.new(storage, output, "52c1cf443ae7407d88000001" => {"algorithm" => "swap"}) }

  after do
    verify do
      DB[:estimates].all.map do |row|
        [[row[:subject_id], row[:user_id], row[:answer], row[:probability].round(20)]]
      end
    end
  end

  context 'with io and sequel' do
    it 'works with the fully integrated kafka-sequel path' do
      File.open(File.expand_path("../../fixtures/spacewarps_ouroboros_classifications.json", __FILE__), 'r') do |io|
        reader = Nero::Input::IOReader.new(io, processor)
        reader.run
      end
    end
  end

  context 'with kafka and sequel', :kafka do
    let(:brokers) { ["kafka:9092"] }
    let(:zookeepers) { ["zk:2181"] }
    let(:topic) { "nero-test-#{Time.now.to_i}"}
    let(:reader) { Nero::Input::KafkaReader.new(processor: processor,
                                                          brokers: brokers,
                                                          zookeepers: zookeepers,
                                                          topic: topic,
                                                          group_name: "group-#{Time.now.to_i}") }

    it 'works with the fully integrated kafka-sequel path' do
      # Single partition to ensure processing in known-order
      producer = Poseidon::Producer.new(brokers, "test_producer", partitioner: ->(partition_count, key) { 0 })

      lines = File.readlines(File.expand_path("../../fixtures/spacewarps_ouroboros_classifications.json", __FILE__))
      messages = lines.map.with_index { |line, idx| Poseidon::MessageToSend.new(topic, line, "message#{idx}") }

      # sending messages in small groups is faster than both singles and larger groups
      messages.each_slice(10) {|slice| producer.send_messages(slice) }

      reader.run
    end
  end
end
