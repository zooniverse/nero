require 'spec_helper'

describe Nero::Blank::BlankSubjectState do
  let(:subject_state) { described_class.new(Nero::SubjectState.new(id: 1, subject_id: 1, workflow_id: 1)) }
  let(:blank_limit) { 5 }

  describe '#retired?' do
    it 'is not retired when four of the first six classifications say the image is blank' do
      subject_state.add_vote 1, "blank"
      subject_state.add_vote 2, "blank"
      subject_state.add_vote 3, "blank"
      subject_state.add_vote 4, "something"
      subject_state.add_vote 5, "blank"
      subject_state.add_vote 6, "something"
      expect(subject_state.retired?(blank_limit)).to eq(false)
    end

    it "is retired when five classifications say the image is blank" do
      subject_state.add_vote 1, "blank"
      subject_state.add_vote 2, "something"
      subject_state.add_vote 3, "blank"
      subject_state.add_vote 4, "something"
      subject_state.add_vote 5, "blank"
      subject_state.add_vote 6, "something"
      subject_state.add_vote 7, "blank"
      subject_state.add_vote 8, "something"
      expect { subject_state.add_vote 9, "blank" }.to change {
        subject_state.retired?(blank_limit)
      }.from(false).to(:blank_consensus)
    end
  end
end
