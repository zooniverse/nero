require 'spec_helper'

module RetirementSwap
  describe Estimate do
    describe '#adjust' do
      let(:estimate) { described_class.new(double("Subject"), double("Workflow")) }
      let(:agent)    { Agent.new(0.6, 0.6) }

      it 'increases in probability when guessing a LENS with an agent that is more than average' do
        next_estimate = estimate.adjust(agent, "LENS")
        expect(next_estimate.probability).to be > estimate.probability
        expect(next_estimate.probability).to eq 0.0002999700029997

      end

      it 'decreases in probability when guessing a NOT' do
        next_estimate = estimate.adjust(agent, "NOT")
        expect(next_estimate.probability).to be < estimate.probability
        expect(next_estimate.probability).to eq 0.00013334222281485435
      end
    end

    describe 'status' do
      it 'is rejected when below threshold' do
        estimate = described_class.new(double, double, nil, nil, 0.000000001)
        expect(estimate.status).to eq(:rejected)
      end

      it 'is rejected when below threshold' do
        estimate = described_class.new(double, double, nil, nil, 0.96)
        expect(estimate.status).to eq(:detected)
      end

      it 'is active otherwise' do
        estimate = described_class.new(double, double, nil, nil, 0.5)
        expect(estimate.status).to eq(:active)
      end
    end
  end
end