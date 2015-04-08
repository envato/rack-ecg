require 'rspec'
require 'rack/test'
require 'rack/ecg'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.disable_monkey_patching!

  config.warnings = true

  config.profile_examples = 10

  config.include Rack::Test::Methods
end
