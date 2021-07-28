source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.2'

gem 'bootsnap', '>= 1.4.4', require: false
gem 'config'
gem 'dotenv-rails'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.3'
gem 'rails', '~> 6.1.4'
gem 'redis'
gem 'redis-namespace'
gem 'rest-client'
gem 'rotp'
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
  gem 'rubocop', require: false
  gem 'rubocop-performance'
  gem 'rubocop-rails', require: false
end

group :test do
  gem 'mock_redis'
  gem 'rspec-rails', '~> 5.0'
  gem 'rspec-sidekiq'
  gem 'simplecov', require: false
  gem 'simplecov-rcov'
  gem 'webmock'
end

group :development do
  gem 'listen', '~> 3.6'
  gem 'spring'
end

gem 'tzinfo-data'
