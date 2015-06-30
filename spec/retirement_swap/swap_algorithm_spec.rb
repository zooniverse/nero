require 'spec_helper'

describe RetirementSwap::SwapAlgorithm do
  include Fixtures

  let(:storage) { RetirementSwap::Storage::Memory.new }
  let(:panoptes) { spy("Panoptes") }
  let(:classification) { fixture(:panoptes_classification)["classifications"][0] }
  subject(:strategy) { described_class.new(storage, panoptes, threshold: 2) }

  it 'processes a message' do
    strategy.process(classification)
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
end
