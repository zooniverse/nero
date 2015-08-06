require 'spec_helper'

describe Nero::Agent do
  describe '#skill' do
    it 'returns 1.0 for a perfect classifier' do
      agent = described_class.new(id: nil, external_id: nil, pl: 1.0, pd: 1.0)
      expect(agent.skill).to eq(1.0)
    end

    it 'returns 0.0 for a random classifier' do
      agent = described_class.new(id: nil, external_id: nil, pl: 0.5, pd: 0.5)
      expect(agent.skill).to eq(0.0)
    end
  end
end
