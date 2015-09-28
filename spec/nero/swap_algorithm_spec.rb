require 'spec_helper'

describe Nero::SwapAlgorithm do
  include Fixtures

  let(:storage) { Nero::Storage.new(DB) }
  let(:panoptes) { spy("Panoptes") }
  let(:subj) { double("Subject", attributes: {"metadata" => {"training" => [{"type" => "lensing cluster"}]}}) }
  let(:classification) { double("Classification", user_id: 1, subjects: [subj], hash: {"annotations" => []}) }
  let(:agent) { double(id: 1, data: {"pl" => 0.9, "pd" => 0.9}, attributes: {}, external_id: '1') }
  let(:estimate) { Nero::Estimate.new(id: nil, subject_id: 1, workflow_id: 2, data: {}) } # active?: true, retired?: false, adjust: new_estimate) }

  subject(:strategy) { described_class.new(storage, panoptes) }

  it 'processes a message' do
    strategy.process(classification, agent, estimate)
  end

  context 'when a subject is a training subject' do
    context 'and it is a known lens' do
      context 'then classifying it as a lens'
      context 'then classifying it as a dud'
    end

    context 'and it is a known dud' do
      context 'then classifying it as a lens'
      context 'then classifying it as a dud'
    end
  end

  context 'when a subject is to be determined' do
  end

  context 'when a subject is over the estimation threshold' do
    context 'and it has been seen by a skilled agent' do
      let(:subj) { double("Subject", attributes: {"metadata" => {}}) }
      let(:estimate) { Nero::Estimate.new(id: nil, subject_id: 1, workflow_id: 2, data: {"guesses" => [{"probability" => Nero::Swap::SwapEstimate::REJECTION_THRESHOLD}]}) }

      it 'retires the subj' do
        strategy.process(classification, agent, estimate)
        expect(panoptes).to have_received(:retire).once
      end
    end

    context 'and it has not been seen by a skilled agent' do
      let(:subj) { double("Subject", test?: true) }
      let(:old_estimate) { double("old estimate", adjust: new_estimate, data: {}, retired?: false, active?: true) }
      let(:new_estimate) { double("new estimate", seen_by?: false, retired?: true, probability: 0.5, attributes: {}) }

      it 'enqueues the subject for known skilled agents' do
        pending
        DB[:agents].insert(external_id: 'unskilled', data: Sequel.pg_jsonb("skill" => 0.4))
        DB[:agents].insert(external_id: 'skilled-1', data: Sequel.pg_jsonb("skill" => 0.94))
        DB[:agents].insert(external_id: 'skilled-2', data: Sequel.pg_jsonb("skill" => 0.81))

        strategy.process(classification, agent, old_estimate)
        expect(panoptes).to have_received(:enqueue).with(['skilled-1', 'skilled-2']).once
      end
    end
  end
end
