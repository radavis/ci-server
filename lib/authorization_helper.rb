module AuthorizationHelper
  def authorize_github(token)
    halt 403 if token != ENV["GITHUB_WEBHOOK_TOKEN"] && ENV["RACK_ENV"] != "development"
  end
end
