require 'spec_helper'

describe Nero::TranscribeHack::TranscribeHackAlgorithm do
  let(:storage) { Nero::Storage.new(DB) }
  let(:panoptes) { spy("Panoptes") }
  let(:subj) { double("Subject", attributes: {"metadata" => {"training" => [{"type" => "lensing cluster"}]}}) }
  let(:classification1) { double("Classification", id: 1, subject_ids: [1], user_id: 1, flagged?: false, subjects: [subj], hash: {"annotations" => []}) }
  let(:classification2) { double("Classification", id: 2, subject_ids: [1], user_id: 1, flagged?: false, subjects: [subj], hash: {"annotations" => []}) }
  let(:user_state) { double(id: 1, data: {"pl" => 0.9, "pd" => 0.9}, attributes: {}, external_id: '1') }
  let(:subject_state) { Nero::SubjectState.new(id: nil, subject_id: 1, workflow_id: 2, data: {}) } # active?: true, retired?: false, adjust: new_subject_state) }

  let(:algorithm) { described_class.new(storage, panoptes) }

  it 'adds subjects to a set' do
    algorithm.process(classification1, user_state, subject_state)
    algorithm.process(classification2, user_state, subject_state)
    expect(panoptes).to have_received(:add_subjects_to_subject_set).once
  end
end
