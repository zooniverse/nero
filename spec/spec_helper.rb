Dir[File.expand_path("../support/**/*.rb", __FILE__)].each { |f| require f }

require 'approvals/rspec'

require 'nero'

RSpec.configure do |config|
  config.before(:example) do
    Nero::Storage.migrate(DB)
    DB[:agents].delete
    DB[:estimates].delete
  end
end
