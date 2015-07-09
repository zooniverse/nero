require 'spec_helper'

describe 'Golden masters' do
  let(:storage)         { RetirementSwap::Storage::Memory.new }
  let(:output)          { RetirementSwap::Output::IOWriter.new(StringIO.new) }
  let(:retirement_swap) { RetirementSwap::SwapAlgorithm.new(storage, output) }

  it 'returns the correct results for the old spacewarps data' do
    storage = RetirementSwap::Storage::Memory.new
    output = RetirementSwap::Output::IOWriter.new(StringIO.new)
    retirement_swap = RetirementSwap::SwapAlgorithm.new(storage, output)

    classifications = File.readlines(File.expand_path("../../fixtures/spacewarps_ouroboros_classifications.json", __FILE__))
                          .map {|line| JSON.parse(line) }

    verify do
      classifications.map { |classification| retirement_swap.process(classification) }
                     .map { |estimates| estimates.map { |estimate| [estimate.subject_id, estimate.user_id, estimate.answer, estimate.probability] } }
    end
  end

  context 'with kafka and sequel' do
    let(:db) { Sequel.sqlite }
    let(:storage) { RetirementSwap::Storage::Database.new(db) }
    let(:output) { RetirementSwap::Output::IOWriter.new(StringIO.new) }
    let(:retirement_swap) { RetirementSwap::SwapAlgorithm.new(storage, output) }
    let(:brokers) { ["kafka:9092"] }
    let(:zookeepers) { ["zk:2181"] }
    let(:topic) { "retirement-swap-test-#{Time.now.to_i}"}
    let(:reader) { RetirementSwap::Input::KafkaReader.new(processor: retirement_swap,
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

      verify do
        db[:estimates].all.map do |row|
          [[row[:subject_id], row[:user_id], row[:answer], row[:probability]]]
        end
      end
    end
  end
end
