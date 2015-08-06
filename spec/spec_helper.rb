Dir[File.expand_path("../support/**/*.rb", __FILE__)].each { |f| require f }

require 'approvals/rspec'

require 'retirement_swap'

RSpec.configure do |config|
  config.before(:example) do
    RetirementSwap::Storage.migrate(DB)
    DB[:agents].delete
    DB[:estimates].delete
  end
end
