require 'rubygems'
require 'bundler/setup'

require_relative 'lib/nero'

run Rack::URLMap.new \
  "/" => Nero::Web

