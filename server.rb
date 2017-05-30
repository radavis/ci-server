require "dotenv"
Dotenv.load
require "bundler/setup"
Bundler.require(:default, ENV["RACK_ENV"])

require_relative "./lib/database"

helpers do
  def authorize_github(token)
    halt 403 if token != ENV["GITHUB_WEBHOOK_TOKEN"] && ENV["RACK_ENV"] != "development"
  end
end

before { @db = Database.new }

get "/" do
  "ci-server"
end

get "/events" do
  sql = "select * from events order by events.created_at desc"
  @events = @db.execute(sql)
  erb :events
end

post "/events" do
  event = JSON.parse(params[:payload])
  token = event["hook"]["config"]["secret"]
  authorize_github(token)
  @db.execute(
    "insert into events (event_type, body, created_at, updated_at) values (?, ?, ?, ?)",
    [request.env["HTTP_X_GITHUB_EVENT"], params[:payload], Time.new.to_i, Time.new.to_i]
  )
  status 200
end
