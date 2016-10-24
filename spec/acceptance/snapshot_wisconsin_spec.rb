require 'spec_helper'

describe 'Snapshot Wisconsin' do
  let(:storage) { Nero::Storage.new(DB) }
  let(:output) { Nero::Output::IOWriter.new(StringIO.new) }
  let(:processor) do
    Nero::Processor.new(storage, output, "1717" => {
      "algorithm" => "survey",
      task_key: "T1"
    })
  end

  after do
    verify do
      DB[:estimates].all.sort_by { |row| row[:subject_id] }
                        .map { |row| [row[:subject_id], row[:data]] }
    end
  end

  it 'processes' do
    File.open(File.expand_path("../../fixtures/snapshot_wisconsin.json", __FILE__), 'r') do |io|
      reader = Nero::Input::IOReader.new(io, processor)
      reader.run
    end
  end
end
