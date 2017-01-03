require 'spec_helper'

describe Nero::Extractors::SurveyExtractor do
  def make_annotation(choice)
    {
      "task" => "T0",
      "value" => [
        {"choice" => choice, "answers" => {"HWMN" => "1"}, "filters" => {}}
      ]
    }
  end

  let(:annotations) { [make_annotation("OTHER")] }

  let(:classification) do
    Nero::Models::Classification.new("annotations" => annotations, "links" => {"workflow" => "1021"})
  end

  subject(:extractor) { described_class.new }

  describe '#process' do
    it 'converts empty value lists to nothing_here' do
      annotations[0]["value"] = []
      expect(extractor.process(classification)).to eq("choices" => ["NTHNGHR"])
    end

    it 'detects the nothing_here value' do
      annotations[0]["value"][0]["choice"] = "NTHNGHR"
      expect(extractor.process(classification)).to eq("choices" => ["NTHNGHR"])
    end

    it 'detects a single choice' do
      annotations[0]["value"][0]["choice"] = "RCCN"
      expect(extractor.process(classification)).to eq("choices" => ["RCCN"])
    end

    it 'detects a multiple choices' do
      annotations[0]["value"][1] = annotations[0]["value"][0].dup
      annotations[0]["value"][2] = annotations[0]["value"][0].dup

      annotations[0]["value"][0]["choice"] = "RCCN"
      annotations[0]["value"][1]["choice"] = "RCCN"
      annotations[0]["value"][2]["choice"] = "BBN"
      expect(extractor.process(classification)).to eq("choices" => ["RCCN", "RCCN", "BBN"])
    end

    it 'detects a multiple annotations for this task' do
      annotations[0] = make_annotation("RCCN")
      annotations[1] = make_annotation("RCCN")
      annotations[2] = make_annotation("BBN")
      expect(extractor.process(classification)).to eq("choices" => ["RCCN", "RCCN", "BBN"])
    end
  end
end
