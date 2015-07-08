require 'spec_helper'

describe 'Golden masters' do
  let(:storage)         { RetirementSwap::Storage::Memory.new }
  let(:output)          { RetirementSwap::Output::IOWriter.new(StringIO.new) }
  let(:retirement_swap) { RetirementSwap::SwapAlgorithm.new(storage, output) }

  it 'returns the correct results for the old spacewarps data' do
    classifications = File.readlines(File.expand_path("../../fixtures/spacewarps_ouroboros_classifications.json", __FILE__))
                          .map {|line| JSON.parse(line) }

    verify do
      classifications.map { |classification| retirement_swap.process(classification) }
                     .map { |estimates| estimates.map { |estimate| [estimate.subject_id, estimate.user_id, estimate.answer, estimate.probability] } }
    end
  end
end
