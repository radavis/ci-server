RSpec.describe "CI Server" do
  describe "GET /" do
    it "responds with its name" do
      get "/"
      expect(last_response).to be_ok
      expect(last_response.body).to include('ci-server')
    end
  end

  describe "GET /events" do
    it "lists the most recent events" do
      db = Database.new
      body = { example: "body" }.to_json
      sql = "insert into events (event_type, body, processed, created_at, updated_at) values (?, ?, ?, ?, ?)"
      db.execute(sql, ["pong", body, 0, Time.now.to_i, Time.now.to_i])
      db.execute(sql, ["pull request", body, 1, Time.now.to_i, Time.now.to_i])
      db.execute(sql, ["40m dash", body, 1, Time.now.to_i, Time.now.to_i])

      get "/events"
      expect(last_response.body).to include("pull request")
      expect(last_response.body).to include("40m dash")
    end
  end

  describe "POST /events" do
    let(:secret) { "abc123" }
    let(:file) { File.read("./docs/github-event-payload.json") }
    let!(:payload) { JSON.parse(file) }
    before { payload["hook"]["config"]["secret"] = secret }

    it "accepts POST requests from GitHub" do
      ENV["GITHUB_WEBHOOK_TOKEN"] = secret

      post "/events", { payload: payload.to_json }, { "HTTP_X_GITHUB_EVENT" => "ping" }
      expect(last_response).to be_ok
    end

    it "rejects POST requests from unknown entities" do
      ENV["GITHUB_WEBHOOK_TOKEN"] = ""

      post "/events", { payload: payload.to_json }, { "HTTP_X_GITHUB_EVENT" => "ping" }
      expect(last_response).to be_forbidden
    end
  end
end
