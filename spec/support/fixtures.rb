require 'json'

module Fixtures
  def fixture(name)
    content = File.read(File.expand_path("../../fixtures/#{name}.json", __FILE__))
    JSON.parse(content)
  end
end
