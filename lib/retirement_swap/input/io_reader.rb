require 'json'

module RetirementSwap
  module Input
    class IOReader
      attr_reader :io, :processor

      def initialize(io, processor)
        @io = io
        @processor = processor
      end

      def run
        io.each_line do |line|
          next if line.strip == ""
          classification = JSON.parse(line)
          processor.process(classification)
        end
      end
    end
  end
end
