require 'spec_helper'

describe Nero::Equador::EquadorClassification do
  let(:blank)     { [{"task" => "init", "value" => 1}] }
  let(:not_blank) { [{"task" => "init", "value" => 0}, {"task" => "T1", "value" => [{}]}] }

  def make_classification(annotations)
    base = Nero::Classification.new("annotations" => annotations, "links" => {"workflow" => "1810"})
    described_class.new(base)
  end

  describe '#vote' do
    it 'detects blanks from classification step' do
      expect(make_classification(blank).vote).to eq("blank")
    end

    it 'detects not-blanks from classification step' do
      expect(make_classification(not_blank).vote).to eq("something")
    end
  end
end
