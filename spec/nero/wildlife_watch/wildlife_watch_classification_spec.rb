require 'spec_helper'

describe Nero::WildlifeWatch::WildlifeWatchClassification do
  let(:no_answers)    { [] }
  let(:i_see_nothing) { [{"task" => "T1", "value" => [{"choice"=>"NTHNGHR", "answers"=>{}, "filters"=>{}}]}] }
  let(:i_see_deer)    { [{"task" => "T1", "value" => [{"choice" => "DR", "answers" => {"HWMN" => "1", "NGPRSNT" => "N"}, "filters" => {}}]}] }
  let(:i_see_human)   { [{"task" => "T1", "value" => [{"choice" => "HMN", "answers" => {"HWMN" => "1", "NGPRSNT" => "N"}, "filters" => {}}]}] }

  def make_classification(annotations)
    base = Nero::Classification.new("annotations" => annotations, "links" => {"workflow" => "1021"})
    described_class.new(base)
  end

  describe '#vote' do
    it 'detects empty answers' do
      expect(make_classification(no_answers).vote).to eq("blank")
    end

    it 'detects blanks from classification step' do
      expect(make_classification(i_see_nothing).vote).to eq("blank")
    end

    it 'detects humans from classification step' do
      expect(make_classification(i_see_human).vote).to eq("human")
    end

    it 'detects animals' do
      expect(make_classification(i_see_deer).vote).to eq("DR")
    end
  end
end
