require 'spec_helper'

describe Nero::Processor do
  let(:storage) { double("Storage", find_agent: nil, find_estimate: nil) }
  let(:output) { double("Output") }
  let(:config) { {} }

  let(:processed_classifications) { [] }

  before do
    allow_any_instance_of(Nero::Processor::NullAlgorithm).to receive(:process) do |obj, classification, agent, estimate|
      processed_classifications << classification
    end
  end

  let(:data) do
    {
      "classifications" => [{
        "id" => "classification-1",
        "links" => {
          "project" => "project-1",
          "workflow" => "workflow-1",
          "user" => "user-1",
          "subjects" => ["subject-1"]
        }
      }],
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
end
