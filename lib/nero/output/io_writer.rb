module Nero
  module Output
    class IOWriter
      attr_reader :io

      def initialize(io)
        @io = io
      end

      def retire(*args)
        io.puts "<<< Retire: #{args.inspect}"
      end
    end
  end
end
