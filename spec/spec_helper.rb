require 'bundler/setup'
require 'to_wa'
require 'active_record'
require 'database_cleaner'
require './db/configuration'

ActiveRecord::Base.establish_connection(ToWaTestConfiguration::FULL_SET)
DatabaseCleaner.strategy = :truncation

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:all) { DatabaseCleaner.start }
  config.before(:all) { DatabaseCleaner.clean! }
end

class TestRecord < ActiveRecord::Base
  extend ToWa
  has_many :users
end

class User < ActiveRecord::Base
end
