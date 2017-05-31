RSpec.describe "Repositories" do
  let(:db) { Database.new }
  let(:now) { Time.now.to_i }
  let(:id) { 0 }

  before do
    sql = "insert into repositories (name, created_at, updated_at) values (?, ?, ?)"
    db.execute(sql, ["radavis/ci-server", now, now])
    db.execute(sql, ["exloc/app", now - 60 * 60 * 24 * 5, now])
    id = db.last_insert_row_id
  end

  describe "GET /repositories" do
    it "lists repos" do
      get "/repositories"

      expect(last_response.body).to include("radavis/ci-server")
      expect(last_response.body).to include("Added just now")

      expect(last_response.body).to include("exloc/app")
      expect(last_response.body).to include("Added 5 days ago")
    end
  end

  describe "PATCH /repositories/:id" do
    it "updates the repository" do
      patch "/repositories/#{id}", {
        configuration_instructions: "bundle && rake db:create db:migrate && rake db:test:prepare",
        build_instructions: "RAILS_ENV=test bundle exec rake spec"
      }
      expect(last_response).to be_ok
    end
  end
end
