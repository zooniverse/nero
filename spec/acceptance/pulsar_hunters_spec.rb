require 'spec_helper'

describe 'Pulsar Hunters' do
  let(:storage)   { Nero::Storage.new(DB) }
  let(:output)    { double("Output") }

  let(:processor) do
    Nero::Processor.new(storage, output, {
      1224 => {
        "algorithm" => "pulsar_hunters",
        "gold_standard_limit" => 120,
        "normal_limit" => 30
      }
    })
  end

  describe 'approvals' do
    after do
      verify do
        DB[:estimates].all.sort_by { |row| row[:subject_id] }
                          .map { |row| [row[:subject_id], row[:data]] }
      end
    end

    context 'with io and sequel' do
      it 'processes the fixture' do
        File.open(File.expand_path("../../fixtures/pulsar_hunters.json", __FILE__), 'r') do |io|
          reader = Nero::Input::IOReader.new(io, processor)
          reader.run
        end
      end
    end
  end

  describe 'for a disc class subject' do
    let(:data) do
      JSON.parse <<-END
        {"data":{"id":"6070202","annotations":[{"task":"init","value":0}],"created_at":"2016-01-11T20:42:22.792Z","metadata":{},"href":"/classifications/6070202","links":{"project":"764","user":"1","workflow":"1224","subjects":["1383411"]}},"linked":{"subjects":[{"id":"1383411","metadata":{"#PSRb":"","#PSRl":"","#Class":"disc","#PSRdm":"","#PSRra":"","#PSRdec":"","#PSRcage":"","#PSRname":"","#Distance":"","#PSRbsurf":"","#PSRperiod":"","CandidateFile":"disc01.png"},"created_at":"2016-01-11T15:31:46.637Z","updated_at":"2016-01-11T15:31:46.637Z","href":"/subjects/1383411"}]}}
      END
    end

    it 'retires after 150 classifications' do
      119.times { processor.process(data) }
      expect(output).to receive(:retire).once
      processor.process(data)
    end
  end


  describe 'for a known class subject' do
    let(:data) do
      JSON.parse <<-END
        {"data":{"id":"6080003","annotations":[{"task":"init","value":0}],"created_at":"2016-01-11T22:54:02.679Z","metadata":{},"href":"/classifications/6080003","links":{"project":"764","user":"1","workflow":"1224","subjects":["1383443"]}},"linked":{"subjects":[{"id":"1383443","metadata":{"#PSRb":"-33.27","#PSRl":"161.135","#Class":"known","#PSRdm":"15.74","#PSRra":"03:04:33.1","#PSRdec":"+19:32:51.4","#PSRcage":"1.70e+07","#PSRname":"B0301+19","#Distance":"0.95","#PSRbsurf":"1.36e+12","#PSRperiod":"1.387584","CandidateFile":"L168045_SAP1_BEAM10_DM15.46_Z0_ACCEL_Cand_4.pfd.ps.png"},"created_at":"2016-01-11T15:32:05.887Z","updated_at":"2016-01-11T15:32:05.887Z","href":"/subjects/1383443"}]}}
      END
    end

    it 'retires after 150 classifications' do
      119.times { processor.process(data) }
      expect(output).to receive(:retire).once
      processor.process(data)
    end
  end

  describe 'for a normal subject' do
    let(:data) do
      JSON.parse <<-END
        {"data":{"id":"6099291","annotations":[{"task":"init","value":1}],"created_at":"2016-01-12T11:46:51.014Z","metadata":{},"href":"/classifications/6099291","links":{"project":"764","user":"1","workflow":"1224","subjects":["1372661"]}},"linked":{"subjects":[{"id":"1372661","metadata":{"CandidateFile":"HTRU-N_set07_cand022125.png"},"created_at":"2016-01-11T08:51:33.037Z","updated_at":"2016-01-11T08:51:33.037Z","href":"/subjects/1372661"}]}}
      END
    end

    it 'retires after 150 classifications' do
      29.times { processor.process(data) }
      expect(output).to receive(:retire).once
      processor.process(data)
    end
  end

end
