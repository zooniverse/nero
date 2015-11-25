require 'spec_helper'

describe Nero::WildlifeWatch::WildlifeWatchClassification do
  let(:nothing_here)             { [{"task" => "init", "value" => 0}] }
  let(:i_see_human_nothing_more) { [{"task" => "init", "value" => 1}] }
  let(:i_see_human_with_deer)    { [{"task" => "init", "value" => 1}, {"task" => "T1", "value" => [{"choice" => "DR", "answers" => {"HWMN" => "1", "NGPRSNT" => "N"}, "filters" => {}}]}] }
  let(:i_see_human_with_human)   { [{"task" => "init", "value" => 1}, {"task" => "T1", "value" => [{"choice" => "HMN", "answers" => {"HWMN" => "1", "NGPRSNT" => "N"}, "filters" => {}}]}] }
  let(:i_see_animal_with_deer)   { [{"task" => "init", "value" => 2}, {"task" => "T1", "value" => [{"choice" => "DR", "answers" => {"HWMN" => "1", "NGPRSNT" => "N"}, "filters" => {}}]}] }
  let(:i_see_animal_with_human)  { [{"task" => "init", "value" => 2}, {"task" => "T1", "value" => [{"choice" => "HMN", "answers" => {"HWMN" => "1", "NGPRSNT" => "N"}, "filters" => {}}]}]}

  def make_classification(annotations)
    base = Nero::Classification.new("annotations" => annotations)
    described_class.new(base)
  end

  describe '#vote' do
    it 'detects blanks' do
      expect(make_classification(nothing_here).vote).to eq("blank")
    end

    it 'detects humans from initial question' do
      expect(make_classification(i_see_human_nothing_more).vote).to eq("human")
    end

    it 'detects humans from classification step' do
      expect(make_classification(i_see_animal_with_human).vote).to eq("human")
    end

    it 'detects animals' do
      expect(make_classification(i_see_animal_with_deer).vote).to eq("animal")
    end
  end
end
