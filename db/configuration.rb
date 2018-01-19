class ToWaTestConfiguration
  BASE = {
    adapter: :mysql2,
    host: ENV['DB_HOST'] || '127.0.0.1',
    port: ENV['DB_PORT'] || '3306',
    username: ENV['DB_USER'] || 'root',
    password: ENV['DB_PASSWORD'] || '',
  }.freeze

  DB_NAME = 'to_wa_test_database'.freeze

  FULL_SET = BASE.merge(
    database: DB_NAME,
  )
end
