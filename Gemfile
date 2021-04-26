source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.1'

gem 'bootsnap', '>= 1.4.4', require: false
gem 'config'
gem 'dotenv-rails'
gem 'jwt'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.3'
gem 'rails', '~> 6.1.3'
gem 'redis'
gem 'redis-namespace'
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
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'mock_redis'
  gem 'rspec-rails', '~> 5.0'
  gem 'simplecov', require: false
  gem 'simplecov-rcov'
end

group :development do
  gem 'listen', '~> 3.3'
  gem 'spring'
end

gem 'tzinfo-data'
