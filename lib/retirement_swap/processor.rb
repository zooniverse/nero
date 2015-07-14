module RetirementSwap
  class Processor
    ALGORITHMS = {
      'swap' => RetirementSwap::SwapAlgorithm
    }

    attr_reader :projects

    def initialize(storage, output, config)
      @projects = {}

      config.each do |project_id, project_config|
        @projects[project_id] = ALGORITHMS.fetch(project_config.fetch('algorithm')).new(storage, output)
      end
    end

    def process(hash)
      project_id = hash.fetch('links').fetch('project')
      projects[project_id] && projects[project_id].process(hash)
    end
  end
end
