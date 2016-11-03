require 'spec_helper'

describe Nero::Blank::BlankAlgorithm do
  let(:subject_state) do
    Nero::Blank::BlankSubjectState.new(
      Nero::SubjectState.new(id: 1, subject_id: 1, workflow_id: 1)
    )
  end
  let(:task_key) { "T1" }
  let(:blank_limit) { 5 }
  let(:options) do
    {
      'task_key' => task_key,
      'blank_consensus_limit' => blank_limit
    }
  end
  let(:empty_annotations) { [{"task" => task_key, "value" => []}] }
  let(:classification) do
    double("Classification", id: 5, user_id: 1, flagged?: false, subject_ids: [1], hash: {"annotations" => empty_annotations})
  end
  let(:panoptes) { instance_double(Nero::Output::PanoptesApi, retire: true) }
  let(:storage) { double(record_subject_state: true) }
  let(:algorithm) { described_class.new(storage, panoptes, options) }

  describe '#process' do
    before do
      subject_state.add_vote 1, "blank"
      subject_state.add_vote 2, "blank"
      subject_state.add_vote 3, "blank"
      subject_state.add_vote 4, "blank"
    end

    it "should update the subject state to be correcly retired" do
      expect {
        algorithm.process(classification, double, subject_state)
      }.to change {
        subject_state.retired?(blank_limit)
      }.from(false).to(:blank_consensus)
    end

    it "should retire the subject with the correct reason" do
      expect(panoptes).to receive(:retire).with(anything, reason: 'blank')
      algorithm.process(classification, double, subject_state)
    end
  end
end
