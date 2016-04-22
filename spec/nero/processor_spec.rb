require 'spec_helper'

describe Nero::Processor do
  let(:storage) { double("Storage", find_user_state: nil, find_subject_state: nil) }
  let(:output) { double("Output") }
  let(:config) { {} }

  let(:processed_classifications) { [] }

  before do
    allow_any_instance_of(Nero::Processor::NullAlgorithm).to receive(:process) do |obj, classification, user_state, subject_state|
      processed_classifications << classification
    end
  end

  let(:data) do
    {
      "data" => {
        "id" => "classification-1",
        "links" => {
          "project" => "project-1",
          "workflow" => "workflow-1",
          "user" => "user-1",
          "subjects" => ["subject-1"]
        }
      },
      "linked" => {
        "subjects" => [{
          "id" => "subject-1",
          "metadata" => {"Filename" => "1.jpg"}
        }]
      }
    }
  end

  it 'makes linked subjects available' do
    processor = described_class.new(storage, output, config)
    processor.process(data)
    expect(processed_classifications[0].subjects[0]).to be_a(Nero::Subject)
  end

  it 'notifies Honeybadger in case a workflow implementation crashes' do
    always_crashes = Class.new do
      def process(*args)
        raise 'Oops'
      end
    end

    stub_const("Honeybadger", double("Honey Badger").as_null_object)
    stub_const("Nero::Processor::NullAlgorithm", always_crashes)

    processor = described_class.new(storage, output, config)
    processor.process(data)

    expect(Honeybadger).to have_received(:notify).once
  end
end
