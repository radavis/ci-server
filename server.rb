require "dotenv"
Dotenv.load
require "bundler/setup"
Bundler.require(:default, ENV["RACK_ENV"])

require_relative "./lib/database"

before { @db = Database.new }

get "/" do
  "ci-server"
end

post "/events" do
  event = JSON.parse(params[:payload])

  if (event["hook"]["config"]["secret"] == ENV["GITHUB_WEBHOOK_TOKEN"]) ||
    (ENV["RACK_ENV"] == "development")

    @db.execute(
      "insert into events (event_type, body, created_at) values (?, ?, ?)",
      [request.env["HTTP_X_GITHUB_EVENT"], params[:payload], Time.new.to_i]
    )
    status 200

  else
    halt 403
  end
end
