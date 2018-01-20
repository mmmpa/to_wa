require 'active_record'

require './db/configuration'
require './db/migration'

ActiveRecord::Base.establish_connection(ToWaTestConfiguration::BASE)
begin
  ActiveRecord::Base.connection.create_database(ToWaTestConfiguration::DB_NAME)
rescue ActiveRecord::StatementInvalid => e
  puts e
end

ActiveRecord::Base.establish_connection(ToWaTestConfiguration::FULL_SET)
ToWaTestMigration.down
ToWaTestMigration.up
