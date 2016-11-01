require 'spec_helper'

describe Nero::Survey::SurveyClassification do
  let(:classification)   { [{"task" => "T0", "value" => [{"choice" => "OTHER", "answers" => {"HWMN" => "1"}, "filters" => {}}]}] }

  def make_classification(annotations)
    base = Nero::Classification.new("annotations" => annotations, "links" => {"workflow" => "1021"})
    described_class.new(base)
  end

  describe '#vote' do
    it 'detects blanks from classification step' do
      classification[0]["value"][0]["choice"] = "NTHNGHR"
      expect(make_classification(classification).vote("T0")).to eq("blank")
    end

    it 'detects humans from classification step' do
      classification[0]["value"][0]["choice"] = "HMN"
      expect(make_classification(classification).vote("T0")).to eq("human")
    end

    it 'detects humans from classification step' do
      %w(MTRZDVHCL VHCL).each do |vehicle_code|
        classification[0]["value"][0]["choice"] = vehicle_code
        expect(make_classification(classification).vote("T0")).to eq("vehicle")
      end
    end

    it 'detects animals' do
      classification[0]["value"][0]["choice"] = "RCCN"
      expect(make_classification(classification).vote("T0")).to eq("RCCN")
    end
  end
end
