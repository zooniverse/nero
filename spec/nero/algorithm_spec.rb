require 'spec_helper'

describe Nero::Algorithm do
  let(:storage) { double("Storage", find_agent: nil, find_estimate: nil) }
  let(:user_state) { double("UserState") }
  let(:subject_state) { double("SubjectState") }
  let(:output) { double("Output", retire: nil) }
  let(:config) { {} }
  let(:algorithm) { described_class.new(storage, output) }

  let(:classification) do
    Nero::Classification.new(
      "id" => "classification-1",
      "metadata" => {
        "subject_flagged" => true
      },
      "links" => {
        "project" => "project-1",
        "workflow" => "workflow-1",
        "user" => "user-1",
        "subjects" => ["subject-1"]
      })
  end

  it 'retires the subject if it is flagged' do
    algorithm.process(classification, user_state, subject_state)
    expect(output).to have_received(:retire).with(subject_state, reason: "flagged").once
  end

  it 'does not retire the subject if the flag was not set by a logged-in user' do
    classification.hash['links']['user'] = nil
    algorithm.process(classification, user_state, subject_state)
    expect(output).to have_received(:retire).exactly(0).times
  end
end
