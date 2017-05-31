RSpec.describe "Repositories" do
  describe "GET /repositories" do
    before do
      db = Database.new
      sql = "insert into repositories (name, created_at, updated_at) values (?, ?, ?)"
      db.execute(sql, ["radavis/ci-server", Time.now.to_i, Time.now.to_i])
      db.execute(sql, ["exloc/app", Time.now.to_i, Time.now.to_i])
    end

    it "lists repos" do
      get "/repositories"
      expect(last_response.body).to include("radavis/ci-server")
      expect(last_response.body).to include("exloc/app")
    end
  end
end
