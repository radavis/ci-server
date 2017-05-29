RSpec.describe "CI Server" do
  describe "GET /" do
    it "responds with its name" do
      get "/"
      expect(last_response).to be_ok
      expect(last_response.body).to include('ci-server')
    end
  end

  describe "POST /events" do
    let(:secret) { "abc123" }
    let(:file) { File.read("./docs/github-event-payload.json") }
    let!(:payload) { JSON.parse(file) }

    it "accepts POST requests from GitHub" do
      ENV["GITHUB_WEBHOOK_TOKEN"] = secret
      payload["hook"]["config"]["secret"] = secret

      post "/events", { payload: payload.to_json }, { "HTTP_X_GITHUB_EVENT" => "ping" }
      expect(last_response).to be_ok
    end

    it "rejects POST requests from unknown entities" do
      ENV["GITHUB_WEBHOOK_TOKEN"] = ""
      payload["hook"]["config"]["secret"] = secret

      post "/events", { payload: payload.to_json }, { "HTTP_X_GITHUB_EVENT" => "ping" }
      expect(last_response).to be_forbidden
    end
  end
end
