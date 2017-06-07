require "net/http"

class Slack
  attr_reader :message, :response

  URL = "https://slack.com/api/chat.postMessage"

  def initialize(message)
    @message = message
    @response = nil
  end

  def post
    @response = Net::HTTP.post_form(uri, options)
    JSON.parse(response.body)
  end

  def options
    {
      token: ENV["SLACK_TOKEN"],
      channel: ENV["SLACK_CHANNEL"],
      text: message,
      as_user: false,
      username: "GigglesCI",
      icon_url: "https://en.gravatar.com/userimage/122608234/6f9cd5c6a7921300c95a2bf800616f7d.png?size=200"
    }
  end

  def uri
    URI(URL)
  end
end
