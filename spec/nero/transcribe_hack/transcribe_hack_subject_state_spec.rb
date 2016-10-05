require 'spec_helper'

describe Nero::Equador::EquadorSubjectState do
  let(:subject_state) { described_class.new(Nero::SubjectState.new(id: 1, subject_id: 1, workflow_id: 1)) }

  describe '#retired?' do
    it "is retired when the three of the first five classifications say the image is blank" do
      subject_state.add_vote 1, "blank"
      subject_state.add_vote 2, "blank"
      subject_state.add_vote 3, "something"
      subject_state.add_vote 4, "something"
      expect { subject_state.add_vote 5, "blank" }.to change { subject_state.retired? }.from(false).to(:three_blanks)
    end

    it 'is not retired when three of the first five classifications says the image is not blank' do
      subject_state.add_vote 1, "blank"
      subject_state.add_vote 2, "something"
      subject_state.add_vote 3, "something"
      subject_state.add_vote 4, "something"
      subject_state.add_vote 5, "blank"
      expect(subject_state.retired?).to eq(false)
    end

    it 'is not retired when three of the first six classifications say the image is not blank' do
      subject_state.add_vote 1, "blank"
      subject_state.add_vote 2, "blank"
      subject_state.add_vote 3, "something"
      subject_state.add_vote 4, "something"
      subject_state.add_vote 5, "something"
      subject_state.add_vote 6, "blank"
      expect(subject_state.retired?).to eq(false)
    end
  end
end
