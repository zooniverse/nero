require 'spec_helper'

module Nero
  module Swap
    describe SwapEstimate do
      describe '#adjust' do
        let(:estimate) { described_class.new(double(data: {})) }
        let(:agent) { double(external_id: nil, pl: 0.6, pd: 0.6) }

        it 'increases in probability when guessing a LENS with an agent that is more than average' do
          previous_probability = estimate.probability
          estimate.adjust(agent, "LENS")
          expect(estimate.probability).to be > previous_probability
        end

        it 'decreases in probability when guessing a NOT' do
          previous_probability = estimate.probability
          estimate.adjust(agent, "NOT")
          expect(estimate.probability).to be < previous_probability
        end
      end

      describe 'status' do
        it 'is rejected when below threshold' do
          estimate = described_class.new(double(data: {"guesses" => [{"probability" => 0.000000001}]}))
          expect(estimate.status).to eq(:rejected)
        end

        it 'is rejected when below threshold' do
          estimate = described_class.new(double(data: {"guesses" => [{"probability" => 0.96}]}))
          expect(estimate.status).to eq(:detected)
        end

        it 'is active otherwise' do
          estimate = described_class.new(double(data: {"guesses" => [{"probability" => 0.5}]}))
          expect(estimate.status).to eq(:active)
        end
      end
    end
  end
end
