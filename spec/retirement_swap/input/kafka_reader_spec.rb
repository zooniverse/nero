require 'spec_helper'

describe RetirementSwap::Input::KafkaReader do
  let(:processor) { spy }
  let(:brokers) { ["192.168.59.103:9092"] }
  let(:reader) { described_class.new(processor: processor,
                                     brokers: brokers,
                                     topics: ['retirement_swap_test'],
                                     consumer_id: 'testreader') }

  it 'forwards classifications to the processor' do
    producer = Poseidon::Producer.new(brokers, "test_producer")
    producer.send_messages([Poseidon::MessageToSend.new("retirement_swap_test", JSON.dump(id: 1))])

    reader.run
    expect(processor).to have_received(:process).with("id" => 1).ordered
  end
end
