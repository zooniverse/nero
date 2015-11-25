require 'spec_helper'

describe Nero::WildlifeWatch::WildlifeWatchEstimate do
  let(:estimate) { described_class.new(Nero::Estimate.new(id: 1, subject_id: 1, workflow_id: 1)) }

  describe '#retired?' do
    it "is retired when any classification says it's a human" do
      estimate.votes << "cow"
      estimate.votes << "cow"
      expect { estimate.votes << "human" }.to change { estimate.retired? }.from(false).to(:human)
    end

    it "is retired when the first three classifications say the image is blank" do
      estimate.votes << "blank"
      estimate.votes << "blank"
      expect { estimate.votes << "blank" }.to change { estimate.retired? }.from(false).to(:three_blanks)
    end

    it 'is not retired when one of the first three classifications says the image is not blank' do
      estimate.votes << "blank"
      estimate.votes << "cow"
      estimate.votes << "blank"
      expect(estimate.retired?).to eq(false)
    end

    it "is retired when five classifications say the image is blank" do
      estimate.votes << "blank"
      estimate.votes << "cow"
      estimate.votes << "blank"
      estimate.votes << "cow"
      estimate.votes << "blank"
      estimate.votes << "cow"
      estimate.votes << "blank"
      estimate.votes << "cow"
      expect { estimate.votes << "blank" }.to change { estimate.retired? }.from(false).to(:five_blanks)
    end

    it "is retired when seven classifications agree" do
      estimate.votes << "cow"
      estimate.votes << "cow"
      estimate.votes << "duck"
      estimate.votes << "cow"
      estimate.votes << "duck"
      estimate.votes << "cow"
      estimate.votes << "cow"
      estimate.votes << "cow"
      expect { estimate.votes << "cow" }.to change { estimate.retired? }.from(false).to(:consensus)
    end
  end
end
