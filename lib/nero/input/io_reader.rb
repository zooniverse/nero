require 'json'

module Nero
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
          data = JSON.parse(line)
          processor.process(data)
        end
      end
    end
  end
end
