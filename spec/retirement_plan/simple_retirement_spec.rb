require 'spec_helper'

describe RetirementPlan::SimpleRetirement do
  include Fixtures

  let(:storage) { RetirementPlan::Storage::Memory.new }
  let(:panoptes) { spy("Panoptes") }
  let(:classification) { fixture(:panoptes_classification)["classifications"][0] }
  subject(:strategy) { described_class.new(storage, panoptes, threshold: 2) }

  it 'processes a message' do
    strategy.process(classification)
  end

  it 'retires a subject after the threshold has been reached' do
    strategy.process(classification)
    strategy.process(classification.merge("links" => classification["links"].merge("user" => 21)))
    expect(panoptes).to have_received(:retire).once
  end
end
