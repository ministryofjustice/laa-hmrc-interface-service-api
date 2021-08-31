source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.2'

gem 'bootsnap', '>= 1.4.4', require: false
gem 'config'
gem 'dotenv-rails'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.4'
gem 'rails', '~> 6.1.4'
gem 'redis'
gem 'redis-namespace'
gem 'rest-client'
gem 'rotp'
gem 'rswag-api'
gem 'rswag-ui'
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'sidekiq'

group :development, :test do
  gem 'byebug'
  gem 'guard-livereload'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'highline'
  gem 'pry-byebug'
  gem 'rspec_junit_formatter'
  gem 'rswag-specs'
  gem 'rubocop', require: false
  gem 'rubocop-performance'
  gem 'rubocop-rails', require: false
end

group :test do
  gem 'mock_redis'
  gem 'rspec-rails', '~> 5.0'
  gem 'rspec-sidekiq'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'simplecov-rcov'
  gem 'vcr'
  gem 'webmock'
end

group :development do
  gem 'listen', '~> 3.7'
  gem 'spring'
end

gem 'tzinfo-data'
