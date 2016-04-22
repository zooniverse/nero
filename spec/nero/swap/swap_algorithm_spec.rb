require 'spec_helper'

describe Nero::Swap::SwapAlgorithm do
  include Fixtures

  let(:storage) { Nero::Storage.new(DB) }
  let(:panoptes) { spy("Panoptes") }
  let(:subj) { double("Subject", attributes: {"metadata" => {"training" => [{"type" => "lensing cluster"}]}}) }
  let(:classification) { double("Classification", user_id: 1, subjects: [subj], hash: {"annotations" => []}) }
  let(:user_state) { double(id: 1, data: {"pl" => 0.9, "pd" => 0.9}, attributes: {}, external_id: '1') }
  let(:subject_state) { Nero::SubjectState.new(id: nil, subject_id: 1, workflow_id: 2, data: {}) } # active?: true, retired?: false, adjust: new_subject_state) }

  subject(:strategy) { described_class.new(storage, panoptes) }

  it 'processes a message' do
    strategy.process(classification, user_state, subject_state)
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
    context 'and it has been seen by a skilled user' do
      let(:subj) { double("Subject", attributes: {"metadata" => {}}) }
      let(:subject_state) { Nero::SubjectState.new(id: nil, subject_id: 1, workflow_id: 2, data: {"guesses" => [{"probability" => Nero::Swap::SwapSubjectState::REJECTION_THRESHOLD}]}) }

      it 'retires the subj' do
        strategy.process(classification, user_state, subject_state)
        expect(panoptes).to have_received(:retire).once
      end
    end

    context 'and it has not been seen by a skilled user' do
      let(:subj) { double("Subject", test?: true) }
      let(:old_subject_state) { double("old subject_state", adjust: new_subject_state, data: {}, retired?: false, active?: true) }
      let(:new_subject_state) { double("new subject_state", seen_by?: false, retired?: true, probability: 0.5, attributes: {}) }

      it 'enqueues the subject for known skilled users' do
        pending
        DB[:agents].insert(external_id: 'unskilled', data: Sequel.pg_jsonb("skill" => 0.4))
        DB[:agents].insert(external_id: 'skilled-1', data: Sequel.pg_jsonb("skill" => 0.94))
        DB[:agents].insert(external_id: 'skilled-2', data: Sequel.pg_jsonb("skill" => 0.81))

        strategy.process(classification, user_state, old_subject_state)
        expect(panoptes).to have_received(:enqueue).with(['skilled-1', 'skilled-2']).once
      end
    end
  end
end
