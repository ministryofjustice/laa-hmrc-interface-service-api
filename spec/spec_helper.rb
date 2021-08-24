# This file was generated by the `rails generate rspec:install` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# The generated `.rspec` file contains `--require spec_helper` which will cause
# this file to always be loaded, without a need to explicitly require it in any
# files.
#
# Given that it is always loaded, you are encouraged to keep this file as
# light-weight as possible. Requiring heavyweight dependencies from this file
# will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, consider making
# a separate helper file that requires the additional dependencies and performs
# the additional setup, and require it from the spec files that actually need
# it.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

require 'simplecov'
require 'highline/import'
require 'webmock'
require 'webmock/rspec'
WebMock.disable_net_connect!
require 'redis'
require 'mock_redis'
REDIS = MockRedis.new
require 'rspec-sidekiq'
require 'sidekiq/testing'

SimpleCov.minimum_coverage 100
unless ENV['NOCOVERAGE']
  SimpleCov.start do
    add_filter 'spec/'
    add_filter 'initializers/config.rb'
    add_filter 'initializers/sidekiq_middleware.rb'
    add_filter 'services/smoke_test.rb'
  end

  SimpleCov.at_exit do
    say("<%= color('Code coverage below 100%', RED) %>") if SimpleCov.result.coverage_statistics[:line].percent < 100
    SimpleCov.result.format!
  end
end

RSpec::Sidekiq.configure do |config|
  config.clear_all_enqueued_jobs = true # default => true
  config.enable_terminal_colours = true # default => true
  config.warn_when_jobs_not_processed_by_sidekiq = false # default => true
end

require 'vcr'

VCR.configure do |vcr_config|
  vcr_config.cassette_library_dir = 'spec/cassettes'
  vcr_config.hook_into :webmock
  vcr_config.configure_rspec_metadata!
  vcr_config.filter_sensitive_data('<SETTINGS__CREDENTIALS__HOST>') do
    ENV['SETTINGS__CREDENTIALS__HOST']
  end
end

RSpec.configure do |config|
  config.filter_run_excluding :smoke_test

  # set up default stub for the host, this can be overwritten in individual stubs if needed
  config.before do
    @hmrc_stub_requests = stub_request(:post, %r{\A#{Settings.credentials.host}/.*\z}).to_return(status: 200, body: '')
  end

  config.before(:each) do
    REDIS.flushdb
  end

  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4 (and will
  # have no way to turn it off -- the option exists only for backwards
  # compatibility in RSpec 3). It causes shared context metadata to be
  # inherited by the metadata hash of host groups and examples, rather than
  # triggering implicit auto-inclusion in groups with matching metadata.
  config.shared_context_metadata_behavior = :apply_to_host_groups
end
