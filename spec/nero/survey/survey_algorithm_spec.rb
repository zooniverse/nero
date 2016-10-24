require 'spec_helper'

describe Nero::Survey::SurveyAlgorithm do
  let(:subject_state) { Nero::Survey::SurveySubjectState.new(Nero::SubjectState.new(id: 1, subject_id: 1, workflow_id: 1)) }
  let(:options) do
    {
      human_limit: 1,
      flagged_limit: 1,
      consensus_limit: 7,
      blank_limit: 3,
      blank_consensus_limit: 5
    }
  end
  let(:algorithm) { described_class.new(double, double, options) }

  describe '#retired?' do
    it "is retired when any classification says it's a human" do
      subject_state.add_vote 1, "RCCN"
      subject_state.add_vote 2, "RCCN"
      expect { subject_state.add_vote 3, "human" }.to change { algorithm.retired?(subject_state) }.from(false).to(:human)
    end

    it "is retired when any classification says it's reported" do
      subject_state.add_vote 1, "RCCN"
      subject_state.add_vote 2, "RCCN"
      expect { subject_state.add_vote 3, "reported" }.to change { algorithm.retired?(subject_state) }.from(false).to(:flagged)
    end


    it "is retired when the first three classifications say the image is blank" do
      subject_state.add_vote 1, "blank"
      subject_state.add_vote 2, "blank"
      expect { subject_state.add_vote 3, "blank" }.to change { algorithm.retired?(subject_state) }.from(false).to(:blank)
    end

    it 'is not retired when one of the first three classifications says the image is not blank' do
      subject_state.add_vote 1, "blank"
      subject_state.add_vote 2, "RCCN"
      subject_state.add_vote 3, "blank"
      expect(algorithm.retired?(subject_state)).to eq(false)
    end

    it "is retired when five classifications say the image is blank" do
      subject_state.add_vote 1, "blank"
      subject_state.add_vote 2, "RCCN"
      subject_state.add_vote 3, "blank"
      subject_state.add_vote 4, "RCCN"
      subject_state.add_vote 5, "blank"
      subject_state.add_vote 6, "RCCN"
      subject_state.add_vote 7, "blank"
      subject_state.add_vote 8, "RCCN"
      expect { subject_state.add_vote 9, "blank" }.to change { algorithm.retired?(subject_state) }.from(false).to(:blank_consensus)
    end

    it "is retired when seven classifications agree" do
      subject_state.add_vote 1, "RCCN"
      subject_state.add_vote 2, "RCCN"
      subject_state.add_vote 3, "duck"
      subject_state.add_vote 4, "RCCN"
      subject_state.add_vote 5, "duck"
      subject_state.add_vote 6, "RCCN"
      subject_state.add_vote 7, "RCCN"
      subject_state.add_vote 8, "RCCN"
      expect { subject_state.add_vote 9, "RCCN" }.to change { algorithm.retired?(subject_state) }.from(false).to(:consensus)
    end
  end
end
