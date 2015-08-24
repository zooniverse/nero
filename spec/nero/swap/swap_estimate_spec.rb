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

      describe '#status' do
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

      describe '#seen_by?' do
        it 'is seen when one of the given user ids matches a guess' do
          estimate = described_class.new(double(data: {"guesses" => [{"user_id" => "bob"}, {"user_id" => "alice"}]}))
          expect(estimate.seen_by?(["alice"])).to be_truthy
        end

        it 'is not seen when no guess matches any of the given user ids' do
          estimate = described_class.new(double(data: {"guesses" => [{"user_id" => "bob"}, {"user_id" => "trudy"}]}))
          expect(estimate.seen_by?(["alice"])).to be_falsey
        end
      end
    end
  end
end
