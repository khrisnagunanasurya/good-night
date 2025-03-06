require 'database_cleaner/active_record'

RSpec.configure do |config|
  # Clean the database before the entire test suite runs
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  # Set the default strategy to transaction (fastest)
  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  # Start the DatabaseCleaner before each test
  config.before(:each) do
    DatabaseCleaner.start
  end

  # Clean the database after each test
  config.after(:each) do
    DatabaseCleaner.clean
  end
end
