$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'rspec'
require 'sqlite3'

require 'encore'

# Require our macros and extensions
Dir[File.expand_path('../../spec/support/macros/**/*.rb', __FILE__)].map(&method(:require))

RSpec.configure do |config|
  # Include our macros
  config.include DatabaseMacros
  config.include ModelMacros

  config.before :each do
    # Setup the database
    setup_database(adapter: 'sqlite3', database: 'encore_test')
  end

  config.before :suite do
    # Enforce available locales (otherwise generating error messages throws a warning)
    I18n.enforce_available_locales = true
  end
end
