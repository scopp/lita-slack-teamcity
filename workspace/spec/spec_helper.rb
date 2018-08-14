require "simplecov"
require "coveralls"
require 'curb'
require 'webmock/rspec'
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter::new
SimpleCov.start { add_filter "/spec/" }

require "lita-slack"
require "lita/handlers/teamcity"
require "lita/rspec"

Lita.version_3_compatibility_mode = false

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
