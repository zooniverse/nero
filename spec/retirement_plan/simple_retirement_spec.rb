require 'spec_helper'

describe RetirementPlan::SimpleRetirement do
  let(:storage) { RetirementPlan::Storage::Memory.new }
  let(:panoptes) { spy("Panoptes") }
  subject(:strategy) { described_class.new(storage, panoptes, threshold: 2) }

  it 'processes a message' do
    strategy.process(id: 1, subject_id: 2, user_id: 3)
  end

  it 'retires a subject after the threshold has been reached' do
    strategy.process(id: 1, subject_id: 2, user_id: 3)
    strategy.process(id: 1, subject_id: 2, user_id: 4)
    expect(panoptes).to have_received(:retire).once
  end
end
