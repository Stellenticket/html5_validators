$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
# load Rails first
require 'rails'
require 'html5_validators'
# needs to load the app before loading rspec/rails => capybara
require 'fake_app'
require 'rspec/rails'
# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.before :all do
    ActiveRecord::Migration.verbose = false
    CreateAllTables.up unless ActiveRecord::Base.connection.table_exists? 'people'
  end
end

def clear_validators
    Person._validators.clear
    Person._validate_callbacks.clear
end

def clear_readonly
    Person._attr_readonly.clear
end
