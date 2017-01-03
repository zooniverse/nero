require 'spec_helper'

describe Nero::Processor do
  let(:storage) { double("Storage", db: DB, find_user_state: nil, find_subject_state: nil) }
  let(:output) { double("Output") }
  let(:config) { {} }

  let(:processed_classifications) { [] }

  before do
    allow_any_instance_of(Nero::Algorithm).to receive(:process) do |_obj, classification, _user_state, _subject_state|
      processed_classifications << classification
    end
  end

  let(:data) do
    {
      "data" => {
        "id" => "1",
        "annotations" => [],
        "metadata" => {},
        "links" => {
          "project" => "1",
          "workflow" => "2",
          "user" => "3",
          "subjects" => ["4"]
        }
      },
      "linked" => {
        "subjects" => [{
          "id" => "4",
          "metadata" => {"Filename" => "1.jpg"}
        }],
        "workflows" => [{
          "id" => "2",
          "links" => {"project" => "1"},
          "retirement" => {}
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
    always_crashes = Class.new(Nero::Algorithm) do
      def process(*args)
        raise 'Oops'
      end
    end

    stub_const("Honeybadger", double("Honey Badger").as_null_object)
    stub_const("Nero::Algorithm", always_crashes)

    processor = described_class.new(storage, output, config)
    processor.process(data)

    expect(Honeybadger).to have_received(:notify).once
  end
end
