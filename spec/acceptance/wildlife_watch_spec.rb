require 'spec_helper'

describe 'Wildlife Watch' do
  let(:storage) { Nero::Storage.new(DB) }
  let(:output) { Nero::Output::IOWriter.new(StringIO.new) }
  let(:processor) do
    Nero::Processor.new(storage, output,
                        "1021" => {"algorithm" => "snapshot_wisconsin"},
                        "1590" => {"algorithm" => "snapshot_wisconsin"})
  end

  after do
    verify do
      DB[:estimates].all.sort_by { |row| row[:subject_id] }
                        .map { |row| [row[:subject_id], row[:data]] }
    end
  end

  it 'processes workflow 1021' do
    File.open(File.expand_path("../../fixtures/wildlife_watch_workflow_1021.json", __FILE__), 'r') do |io|
      reader = Nero::Input::IOReader.new(io, processor)
      reader.run
    end
  end

  it 'processes workflow 1590' do
    File.open(File.expand_path("../../fixtures/wildlife_watch_workflow_1590.json", __FILE__), 'r') do |io|
      reader = Nero::Input::IOReader.new(io, processor)
      reader.run
    end
  end
end
