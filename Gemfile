source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.1'

gem 'bootsnap', '>= 1.4.4', require: false
gem 'config'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'
gem 'rails', '~> 6.1.3', '>= 6.1.3.1'

group :development, :test do
  gem 'byebug'
  gem 'highline'
  gem 'pry-byebug'
  gem 'rubocop', require: false
  gem 'rubocop-performance'
  gem 'rubocop-rails', require: false
end

group :test do
  gem 'rspec-rails', '~> 5.0'
  gem 'simplecov', require: false
  gem 'simplecov-rcov'
end

group :development do
  gem 'listen', '~> 3.3'
  gem 'spring'
end

gem 'tzinfo-data'
