# frozen_string_literal: true

require 'simplecov'

# We don't want simplecov in guard
unless ENV['NO_COVERAGE']
  SimpleCov.start do
    enable_coverage :branch
    add_filter '/spec/'
  end
end

require 'bundler/setup'
require 'root'
require 'pry'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
