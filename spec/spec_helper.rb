# frozen_string_literal: true

require 'bundler/setup'
require 'factory_bot'
require 'timecop'

if ENV['CI'] == 'true'
  require 'simplecov'
  SimpleCov.start

  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require 'fabric'
require_relative 'support/shared_context/client_mocks'
require_relative 'support/shared_context/accessor_shared_contexts'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end
end

RSPEC_ROOT = File.dirname __FILE__
