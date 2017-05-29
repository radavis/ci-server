require "securerandom"

namespace :ci do
  desc "generate a token with SecureRandom.urlsafe_base64"
  task :generate_token do
    puts SecureRandom.urlsafe_base64
  end
end

namespace :db do
  desc "drop database"
  task :drop do
    `rm #{Database.new}`
  end

  desc "create database"
  task :create do
    puts "SQLite does this for you."
  end

  desc "migrate database"
  task :migrate do
    puts "We aren't using migrations. Try 'rake db:schema_load'."
  end

  desc "load database schema"
  task :schema_load do
    `sqlite3 #{Database.new} < ./db/schema.sql`
  end
end

task :default do
  ENV["RACK_ENV"] = "test"
  require_relative "./lib/database"
  require "rspec/core/rake_task"
  Rake::Task["db:schema_load"].invoke
  RSpec::Core::RakeTask.new(:spec)
  Rake::Task[:spec].invoke
end
