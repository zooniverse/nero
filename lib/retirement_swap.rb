require_relative 'retirement_swap/input/io_reader'
require_relative 'retirement_swap/input/kafka_reader'

require_relative 'retirement_swap/storage/memory'
require_relative 'retirement_swap/storage/database'

require_relative 'retirement_swap/output/io_writer'

require_relative 'retirement_swap/agent'
require_relative 'retirement_swap/classification'
require_relative 'retirement_swap/estimate'
require_relative 'retirement_swap/subject'

require_relative 'retirement_swap/swap_algorithm'

module RetirementSwap
end
