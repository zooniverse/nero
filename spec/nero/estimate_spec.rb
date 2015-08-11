require 'spec_helper'

module Nero
  describe Estimate do
    describe '#adjust' do
      let(:estimate) { described_class.new(subject_id: double("Subject"), workflow_id: double("Workflow")) }
      let(:agent) { double(external_id: nil, pl: 0.6, pd: 0.6) }

      it 'increases in probability when guessing a LENS with an agent that is more than average' do
        next_estimate = estimate.adjust(agent, "LENS")
        expect(next_estimate.probability).to be > estimate.probability

      end

      it 'decreases in probability when guessing a NOT' do
        next_estimate = estimate.adjust(agent, "NOT")
        expect(next_estimate.probability).to be < estimate.probability
      end
    end

    describe 'status' do
      it 'is rejected when below threshold' do
        estimate = described_class.new(subject_id: double, workflow_id: double, probability: 0.000000001)
        expect(estimate.status).to eq(:rejected)
      end

      it 'is rejected when below threshold' do
        estimate = described_class.new(subject_id: double, workflow_id: double, probability: 0.96)
        expect(estimate.status).to eq(:detected)
      end

      it 'is active otherwise' do
        estimate = described_class.new(subject_id: double, workflow_id: double, probability: 0.5)
        expect(estimate.status).to eq(:active)
      end
    end
  end
end
