require "dotenv"
Dotenv.load
require "bundler/setup"
Bundler.require(:default, ENV["RACK_ENV"])

require "securerandom"
require_relative "./lib/builder"
require_relative "./lib/database"
require_relative "./lib/emoji"
require_relative "./lib/event_processor"
require_relative "./lib/slack"

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

  desc "create build records from github events. schedule this every (x) seconds."
  task :process_events do
    EventProcessor.engage
  end

  desc "execute the next unstarted build in the queue. schedule this every (x) minutes."
  task :build do
    Builder.build
  end

  desc "announce build results to slack. schedule this every (x) seconds."
  task :announce do
    sql = "select * from builds where exit_status not null and reported = 0"
    completed_builds = Database.execute(sql)
    completed_builds.each do |build|
      passed = build["exitstatus"] == 0
      emoji = passed ? Emoji::POSITIVE.sample : Emoji::NEGATIVE.sample
      message = "The latest build of #{build["repository_name"]} #{passed ? "was a success" : "failed"}. #{emoji}"
      Slack.new(message).post
      # GitHub.announce
      sql = "update builds set reported = 1, updated_at = ? where id = ?"
      Database.execute(sql, [Time.now.to_i, build["id"]])
    end
  end

  desc "print build report"
  task :build_report do
    id = ENV["BUILD_ID"]
    raise "please specify a build id: rake ci:build_report BUILD_ID=3" unless id

    build = Database.execute("select * from builds where id = ?", id).first
    return unless build

    build_report = JSON.parse(build["build_report"])
    puts "Exit Status: #{build["exit_status"]}"
    last_cmd, last_out, last_err, _ = build_report.last
    puts "Last Command: #{last_cmd}"
    puts "Last Result: #{last_err || last_out}"
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

  desc "execute sql query against database"
  task :query do
    sql = ENV["SQL"]
    unless sql
      example_query = "select id, repository_id, event_type, processed, created_at from events"
      raise "Try: rake db:query SQL='#{example_query}'"
    end

    PP.pp Database.new.execute(sql)
  end
end

desc "post slack message"
task :slack do
  message = ENV["MESSAGE"]
  raise "please specify a message: rake slack MESSAGE=\"Microphone check. One, two.\"" unless message
  result = Slack.new(message).post
  PP.pp result
end

task :default do
  ENV["RACK_ENV"] = "test"
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)
  Rake::Task[:spec].invoke
end
