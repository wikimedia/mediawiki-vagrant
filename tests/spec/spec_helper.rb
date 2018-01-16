require 'rspec'
require 'fakefs/spec_helpers'

require_relative 'support/mock_environment'
require_relative 'support/string'

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers, fakefs: true
  config.include MediaWikiVagrant::SpecHelpers::String
end
