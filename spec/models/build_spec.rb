RSpec.describe "Build" do
  let(:repo) {
    Repository.create(
      name: "radavis/ci-server",
      url: "https://github.com/radavis/ci-server",
      build_instructions: "bundle && rake"
  )}

  let(:json_payload) { File.read("./docs/github-push-event.json") }
  let(:event) { repo.events.create(event_type: "push", json_payload: json_payload) }
  let(:build) { event.builds.create }

  describe ".unstarted" do
    it "return builds where started is false" do
      expect(Build.unstarted).to include(build)
    end
  end

  describe "#passed" do
    it "returns true if the exit_code is zero" do
      build.exit_status = 0
      expect(build.passed?).to eq(true)
    end

    it "returns false if the exit_code is non-zero" do
      [-99, 3, 666].each do |exitstatus|
        build.exit_status = exitstatus
        expect(build.passed?).to eq(false)
      end
    end
  end
end
