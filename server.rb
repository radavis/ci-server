require "dotenv"
Dotenv.load
require "bundler/setup"
Bundler.require(:default, ENV["RACK_ENV"])

Dir[File.join(File.dirname(__FILE__), 'lib', '**', '*.rb')].each { |file| require file }
Dir[File.join(File.dirname(__FILE__), 'models', '**', '*.rb')].each { |file| require file }
Dir[File.join(File.dirname(__FILE__), 'workers', '**', '*.rb')].each { |file| require file }

ActiveRecord::Base.establish_connection(Database.config)

helpers do
  include AuthorizationHelper
  include TimeHelper
end

get "/" do
  "ci-server"
end

get "/events" do
  @events = Event.order(created_at: :desc).limit(20)
  erb :events
end

post "/events" do
  authorize_github(request)

  body = request.body.read
  event = JSON.parse(body)
  name = event["repository"]["full_name"]

  repo = Repository.find_or_create_by(name: name)
  repo.events.build(event_type: request.env["HTTP_X_GITHUB_EVENT"], json_payload: body)
  repo.save!

  status 201
end

get "/repositories" do
  @repositories = Repository.order(created_at: :desc).limit(20)
  erb :repositories
end

get "/repositories/:id" do |id|
  @repository = Repository.find(id)
  erb :repository
end

patch "/repositories/:id" do |id|
  repo = Repository.find(id)
  repo.assign_attributes({
    url: params["url"],
    configuration_instructions: params["configuration_instructions"],
    build_instructions: params["build_instructions"]
  })

  if repo.save
    # flash[:notice] = "Repository updated."
  else
    # flash[:error] = "There was a problem."
  end

  redirect to("/repositories/#{repo.id}")
end
