require 'spec_helper'

describe Nero::Survey::SurveyClassification do
  let(:i_see_nothing) { [{"task" => "T0", "value" => [{"choice"=>"NTHNGHR", "answers"=>{}, "filters"=>{}}]}] }
  let(:i_see_raccoon) { [{"task" => "T0", "value" => [{"choice" => "RCCN", "answers" => {"HWMN" => "1"}, "filters" => {}}]}] }
  let(:i_see_human)   { [{"task" => "T0", "value" => [{"choice" => "HMN", "answers" => {"HWMN" => "1"}, "filters" => {}}]}] }

  def make_classification(annotations)
    base = Nero::Classification.new("annotations" => annotations, "links" => {"workflow" => "1021"})
    described_class.new(base)
  end

  describe '#vote' do
    it 'detects blanks from classification step' do
      expect(make_classification(i_see_nothing).vote).to eq("blank")
    end

    it 'detects humans from classification step' do
      expect(make_classification(i_see_human).vote).to eq("human")
    end

    it 'detects animals' do
      expect(make_classification(i_see_raccoon).vote).to eq("RCCN")
    end
  end
end
