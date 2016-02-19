require 'spec_helper'

describe 'Wildlife Watch' do
  let(:storage) { Nero::Storage.new(DB) }
  let(:output) { Nero::Output::IOWriter.new(StringIO.new) }
  let(:processor) { Nero::Processor.new(storage, output, "1021" => {"algorithm" => "wildlife_watch"}) }

  after do
    verify do
      DB[:estimates].all.sort_by { |row| row[:subject_id] }
                        .map { |row| [row[:subject_id], row[:data]] }
    end
  end

  context 'with io and sequel' do
    it 'processes the fixture' do
      File.open(File.expand_path("../../fixtures/wildlife_watch.json", __FILE__), 'r') do |io|
        reader = Nero::Input::IOReader.new(io, processor)
        reader.run
      end
    end
  end
end
