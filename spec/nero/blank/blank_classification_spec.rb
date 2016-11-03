require 'spec_helper'

describe Nero::Blank::BlankClassification do
  let(:task_key) { "T1" }
  let(:blank) { [{"task" => task_key, "value" => []}] }
  let(:not_blank) do
    [
      {
        "task" => task_key,
        "value" => [{
          "x":601.796875,
          "y":357,
          "rx":232.1055794245369,
          "ry":93.59086493883898,
          "tool":0,
          "angle":178.27177234950145,
          "frame":0,
          "details":[]
        }]
      }
    ]
  end

  def make_classification(annotations)
    base = Nero::Classification.new("annotations" => annotations, "links" => {"workflow" => "2245"})
    described_class.new(base)
  end

  describe '#vote' do
    it 'detects blanks from classification step' do
      expect(make_classification(blank).vote(task_key)).to eq("blank")
    end

    it 'detects not-blanks from classification step' do
      expect(make_classification(not_blank).vote(task_key)).to eq("something")
    end
  end
end
