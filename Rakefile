require "dotenv"
Dotenv.load
require "bundler/setup"
Bundler.require(:default, ENV["RACK_ENV"])

require "securerandom"
require_relative "./lib/database"

namespace :ci do
  desc "generate a token with SecureRandom.urlsafe_base64"
  task :generate_token do
    puts SecureRandom.urlsafe_base64
  end

  desc "expose app to internet via ngrok"
  task :ngrok do
    port = ENV["PORT"]
    # Executing shell commands from Ruby: https://stackoverflow.com/a/2400/2675670
    exec("ngrok http #{port}")
  end

  desc "expose app to internet via pagekite"
  task :pagekite do
    host = ENV["PAGEKITE_HOSTNAME"]
    port = ENV["PORT"]
    exec("pagekite.py #{port} #{host}")
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
    puts "We aren't using migrations, yet. Try 'rake db:schema_load'."
  end

  desc "load database schema"
  task :schema_load do
    `sqlite3 #{Database.new} < ./db/schema.sql`
  end
end

task :default do
  ENV["RACK_ENV"] = "test"
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)
  Rake::Task[:spec].invoke
end
