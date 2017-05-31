RSpec.describe "Repositories" do
  describe "GET /repositories" do
    let(:db) { Database.new }
    let(:now) { Time.now.to_i }

    before do
      sql = "insert into repositories (name, created_at, updated_at) values (?, ?, ?)"
      db.execute(sql, ["radavis/ci-server", now, now])
      db.execute(sql, ["exloc/app", now - 60 * 60 * 24 * 5, now])
    end

    it "lists repos" do
      get "/repositories"

      expect(last_response.body).to include("radavis/ci-server")
      expect(last_response.body).to include("Added just now")

      expect(last_response.body).to include("exloc/app")
      expect(last_response.body).to include("Added 5 days ago")
    end
  end
end
