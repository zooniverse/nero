require 'spec_helper'

module Nero
  module Swap
    describe SwapSubjectState do
      describe '#adjust' do
        let(:subject_state) { described_class.new(double(data: {})) }
        let(:user_state) { double(external_id: nil, pl: 0.6, pd: 0.6) }

        it 'increases in probability when guessing a LENS with a user that is more than average' do
          previous_probability = subject_state.probability
          subject_state.adjust(user_state, "LENS")
          expect(subject_state.probability).to be > previous_probability
        end

        it 'decreases in probability when guessing a NOT' do
          previous_probability = subject_state.probability
          subject_state.adjust(user_state, "NOT")
          expect(subject_state.probability).to be < previous_probability
        end
      end

      describe '#status' do
        it 'is rejected when below threshold' do
          subject_state = described_class.new(double(data: {"guesses" => [{"probability" => 0.000000001}]}))
          expect(subject_state.status).to eq(:rejected)
        end

        it 'is rejected when below threshold' do
          subject_state = described_class.new(double(data: {"guesses" => [{"probability" => 0.96}]}))
          expect(subject_state.status).to eq(:detected)
        end

        it 'is active otherwise' do
          subject_state = described_class.new(double(data: {"guesses" => [{"probability" => 0.5}]}))
          expect(subject_state.status).to eq(:active)
        end
      end

      describe '#seen_by?' do
        it 'is seen when one of the given user ids matches a guess' do
          subject_state = described_class.new(double(data: {"guesses" => [{"user_id" => "bob"}, {"user_id" => "alice"}]}))
          expect(subject_state.seen_by?(["alice"])).to be_truthy
        end

        it 'is not seen when no guess matches any of the given user ids' do
          subject_state = described_class.new(double(data: {"guesses" => [{"user_id" => "bob"}, {"user_id" => "trudy"}]}))
          expect(subject_state.seen_by?(["alice"])).to be_falsey
        end
      end
    end
  end
end
