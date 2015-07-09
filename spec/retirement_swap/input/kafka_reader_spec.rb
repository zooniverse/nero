require 'spec_helper'

describe RetirementSwap::Input::KafkaReader do
  let(:processor) { spy }
  let(:brokers) { ["192.168.59.103:9092"] }
  let(:topic) { "retirement-swap-test-#{Time.now.to_i}"}
  let(:reader) { described_class.new(processor: processor,
                                     brokers: brokers,
                                     zookeepers: ['zk:2181'],
                                     topic: topic,
                                     group_name: "group-#{Time.now.to_i}") }

  it 'forwards classifications to the processor' do
    producer = Poseidon::Producer.new(brokers, "test_producer", partitioner: ->(partition, key) { 0 })

    producer.send_messages([
      Poseidon::MessageToSend.new(topic, JSON.dump(id: 1), 'msg1'),
      Poseidon::MessageToSend.new(topic, JSON.dump(id: 2), 'msg2'),
      Poseidon::MessageToSend.new(topic, JSON.dump(id: 3), 'msg3')
    ])

    reader.run

    expect(processor).to have_received(:process).with("id" => 1)
    expect(processor).to have_received(:process).with("id" => 2)
    expect(processor).to have_received(:process).with("id" => 3)
  end
end
