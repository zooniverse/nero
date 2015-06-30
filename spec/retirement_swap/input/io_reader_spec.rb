require 'spec_helper'

describe RetirementSwap::Input::IOReader do
  let(:processor) { spy }

  it 'sends a json-parsed line to the processor' do
    io = StringIO.new('{"json": "parsed"}')
    described_class.new(io, processor).run
    expect(processor).to have_received(:process).with("json" => "parsed")
  end

  it 'sends each line separately' do
    io = StringIO.new <<-END
      {"id": 1}
      {"id": 2}
      {"id": 3}
    END

    described_class.new(io, processor).run
    expect(processor).to have_received(:process).with("id" => 1).ordered
    expect(processor).to have_received(:process).with("id" => 2).ordered
    expect(processor).to have_received(:process).with("id" => 3).ordered
  end
end
