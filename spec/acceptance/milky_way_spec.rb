require 'spec_helper'

describe 'Milky Way' do
  let(:storage) { Nero::Storage.new(DB) }
  let(:output) { Nero::Output::IOWriter.new(StringIO.new) }
  let(:options) do
    {"algorithm" => "blank", "task_key" => "T1", "blank_consensus" => 2}
  end
  let(:processor) do
    Nero::Processor.new(storage, output, "2245" => options )
  end

  after do
    verify do
      DB[:estimates].all
                    .sort_by { |row| row[:subject_id] }
                    .map { |row| [row[:subject_id], row[:data]] }
    end
  end

  it 'processes workflow 2245' do
    File.open(File.expand_path("../../fixtures/milky_way_workflow_2245.json", __FILE__), 'r') do |io|
      reader = Nero::Input::IOReader.new(io, processor)
      reader.run
    end
  end
end
