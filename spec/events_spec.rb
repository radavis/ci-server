RSpec.describe "Events" do
  describe "GET /events" do
    let(:db) { Database.new }
    let(:name) { "rails/rails" }
    let(:now) { Time.now.to_i }
    let(:payload) { { example: "body" }.to_json }

    before do
      sql = "insert or ignore into repositories (name, created_at, updated_at) values (?, ?, ?)"
      values = [name, now, now]
      db.execute(sql, values)
      repository_id = db.execute("select id from repositories where name = ? limit 1", [name])[0]["id"]

      sql = "insert into events (repository_id, event_type, json_payload, created_at, updated_at) values (?, ?, ?, ?, ?)"
      db.execute(sql, [repository_id, "pong", payload, now, now])
      db.execute(sql, [repository_id, "pull request", payload, now, now])
      db.execute(sql, [repository_id, "40m dash", payload, now, now])
    end

    it "lists events" do
      get "/events"
      expect(last_response.body).to include("pong")
      expect(last_response.body).to include("pull request")
      expect(last_response.body).to include("40m dash")
    end
  end

  describe "POST /events" do
    let(:json) { File.read("./docs/github-event-payload.json") }
    let(:payload) { JSON.parse(json) }

    before { ENV["GITHUB_WEBHOOK_TOKEN"] = "abc123" }

    it "accepts POST requests from GitHub" do
      payload["hook"]["config"]["secret"] = "abc123"
      post "/events", { payload: payload.to_json }, { "HTTP_X_GITHUB_EVENT" => "ping" }
      expect(last_response).to be_ok
    end

    it "rejects POST requests from unknown entities" do
      payload["hook"]["config"]["secret"] = "xyz987"
      post "/events", { payload: payload.to_json }, { "HTTP_X_GITHUB_EVENT" => "ping" }
      expect(last_response).to be_forbidden
    end
  end
end
