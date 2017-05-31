RSpec.describe "CI Server" do
  describe "GET /" do
    it "responds with its name" do
      get "/"
      expect(last_response).to be_ok
      expect(last_response.body).to include('ci-server')
    end
  end
end
