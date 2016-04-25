require 'spec_helper'

describe Nero::WildlifeWatch::WildlifeWatchSubjectState do
  let(:subject_state) { described_class.new(Nero::SubjectState.new(id: 1, subject_id: 1, workflow_id: 1)) }

  describe '#retired?' do
    it "is retired when any classification says it's a human" do
      subject_state.add_vote "cow"
      subject_state.add_vote "cow"
      expect { subject_state.add_vote "human" }.to change { subject_state.retired? }.from(false).to(:human)
    end

    it "is retired when the first three classifications say the image is blank" do
      subject_state.add_vote "blank"
      subject_state.add_vote "blank"
      expect { subject_state.add_vote "blank" }.to change { subject_state.retired? }.from(false).to(:three_blanks)
    end

    it 'is not retired when one of the first three classifications says the image is not blank' do
      subject_state.add_vote "blank"
      subject_state.add_vote "cow"
      subject_state.add_vote "blank"
      expect(subject_state.retired?).to eq(false)
    end

    it "is retired when five classifications say the image is blank" do
      subject_state.add_vote "blank"
      subject_state.add_vote "cow"
      subject_state.add_vote "blank"
      subject_state.add_vote "cow"
      subject_state.add_vote "blank"
      subject_state.add_vote "cow"
      subject_state.add_vote "blank"
      subject_state.add_vote "cow"
      expect { subject_state.add_vote "blank" }.to change { subject_state.retired? }.from(false).to(:five_blanks)
    end

    it "is retired when seven classifications agree" do
      subject_state.add_vote "cow"
      subject_state.add_vote "cow"
      subject_state.add_vote "duck"
      subject_state.add_vote "cow"
      subject_state.add_vote "duck"
      subject_state.add_vote "cow"
      subject_state.add_vote "cow"
      subject_state.add_vote "cow"
      expect { subject_state.add_vote "cow" }.to change { subject_state.retired? }.from(false).to(:consensus)
    end
  end
end
