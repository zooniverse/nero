require 'spec_helper'

describe 'Golden masters' do
  let(:storage) { Nero::Storage.new(DB) }
  let(:output) { Nero::Output::IOWriter.new(StringIO.new) }
  let(:processor) { Nero::Processor.new(storage, output, "52c1cf443ae7407d88000001" => {"algorithm" => "swap"}) }

  after do
    verify do
      DB[:estimates].all.flat_map { |row| (row[:data]["guesses"] || []).map { |guess| guess.merge(row) } }
                        .sort_by { |row| row["timestamp"] }
                        .map { |row| [[row[:subject_id], row["user_id"], row["answer"], row["probability"].round(10)]] }
    end
  end

  context 'with io and sequel' do
    it 'processes the spacewarps fixture' do
      File.open(File.expand_path("../../fixtures/spacewarps.json", __FILE__), 'r') do |io|
        reader = Nero::Input::IOReader.new(io, processor)
        reader.run
      end
    end
  end
end
