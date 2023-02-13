source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.0"

gem "aws-sdk-s3", require: false
gem "bootsnap", ">= 1.4.4", require: false
gem "config"
gem "doorkeeper", "~> 5.5.4", "< 5.6"
gem "dotenv-rails"
gem "net-imap"
gem "net-pop"
gem "net-smtp"
gem "pg", "~> 1.4"
gem "puma", "~> 6.1"
gem "rails", "~> 7.0.4"
gem "redis-namespace"
gem "rest-client"
gem "rotp"
gem "rswag-api"
gem "rswag-ui"
gem "sentry-rails"
gem "sentry-ruby"
gem "sidekiq", "~> 7.0"
gem "timeliness-i18n"

group :development, :test do
  gem "byebug"
  gem "factory_bot_rails", ">= 6.2.0"
  gem "faker", ">=1.9.1"
  gem "guard-livereload"
  gem "guard-rspec"
  gem "guard-rubocop"
  gem "highline"
  gem "pry-byebug"
  gem "rspec_junit_formatter"
  gem "rswag-specs"
  gem "rubocop-govuk", require: false
  gem "rubocop-performance"
end

group :test do
  gem "mock_redis"
  gem "rspec-rails", "~> 6.0"
  gem "rspec-sidekiq"
  gem "shoulda-matchers"
  gem "simplecov", require: false
  gem "simplecov-rcov"
  gem "vcr"
  gem "webmock"
end

group :development do
  gem "listen", "~> 3.8"
  gem "spring"
end

gem "tzinfo-data"
