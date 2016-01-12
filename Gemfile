source 'https://rubygems.org'

gem 'rake'
gem 'poseidon'
gem 'poseidon_cluster'
gem 'sequel'
gem 'pg'
gem 'newrelic_rpm'
gem 'honeybadger', '~> 2.0'
gem 'faraday'
gem 'faraday_middleware'
gem 'faraday-panoptes'

group :development do
  gem 'rerun'
end

group :development, :test do
  gem 'pry'
  gem 'awesome_print'

  gem 'sqlite3'

  # To compare against old implementation
  gem 'mongo', '~> 2.0'
end

group :test do
  gem 'rspec'
  gem 'approvals'
  gem 'webmock'
end
