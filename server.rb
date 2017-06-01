require "dotenv"
Dotenv.load
require "bundler/setup"
Bundler.require(:default, ENV["RACK_ENV"])

require_relative "./lib/authorization_helper"
require_relative "./lib/time_helper"
require_relative "./lib/database"

helpers do
  include AuthorizationHelper
  include TimeHelper
end

before { @db = Database.new }

get "/" do
  "ci-server"
end

get "/events" do
  sql = "select * from events order by events.created_at desc limit 20"
  @events = @db.execute(sql)
  erb :events
end

post "/events" do
  authorize_github(request)

  body = request.body.read
  event = JSON.parse(body)

  # store repository
  name = event["repository"]["full_name"]
  sql = "insert or ignore into repositories (name, created_at, updated_at) values (?, ?, ?)"
  values = [name, now, now]
  @db.execute(sql, values)
  repository_id = @db.execute("select id from repositories where name = ?", [name]).first["id"]

  # store event
  sql = <<-SQL
    insert into events (repository_id, event_type, json_payload, created_at, updated_at)
    values (?, ?, ?, ?, ?)
  SQL
  values = [repository_id, request.env["HTTP_X_GITHUB_EVENT"], body, now, now]
  @db.execute(sql, values)

  status 201
end

get "/repositories" do
  sql = "select * from repositories order by repositories.created_at desc limit 20"
  @repositories = @db.execute(sql)
  erb :repositories
end

patch "/repositories/:id" do |id|
  sql = <<-SQL
    update repositories
    set
      configuration_instructions = ?,
      build_instructions = ?,
      updated_at = ?
    where id = ?
  SQL
  values = [params["configuration_instructions"], params["build_instructions"], now, id]
  @db.execute(sql, values)

  status 200
end
