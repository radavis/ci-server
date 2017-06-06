RSpec.describe "Event" do
  let(:json_payload) { File.read("./docs/github-push-event.json") }
  let(:ci_server) do
    Repository.create({
      name: "radavis/ci-server",
      url: "https://github.com/radavis/ci-server.git",
      build_instructions: "bundle && rake"
    })
  end

  let(:exloc) do
    Repository.create({
      name: "exloc/app",
      url: "https://github.com/exloc/app.git",
      build_instructions: nil
    })
  end

  let!(:unprocessed_push) { ci_server.events.create({ event_type: "push", processed: false, json_payload: json_payload }) }
  let!(:processed_sync) { ci_server.events.create({ event_type: "sync", processed: true, json_payload: json_payload }) }
  let!(:processed_push) { exloc.events.create({ event_type: "push", processed: true, json_payload: json_payload }) }

  describe ".unprocessed" do
    it "returns events where processed is false" do
      expect(Event.unprocessed).to include(unprocessed_push)
      expect(Event.unprocessed).to_not include(processed_sync)
      expect(Event.unprocessed).to_not include(processed_push)
    end
  end

  describe ".pushes" do
    it "returns events where the event_type is set to 'push'" do
      expect(Event.pushes).to include(unprocessed_push)
      expect(Event.pushes).to_not include(processed_sync)
      expect(Event.pushes).to include(processed_push)
    end
  end

  describe ".with_configured_repository" do
    it "returns events that have an associated configured repo" do
      expect(Event.with_configured_repository).to include(unprocessed_push)
      expect(Event.with_configured_repository).to include(processed_sync)
      expect(Event.with_configured_repository).to_not include(processed_push)
    end
  end

  describe ".processable" do
    it "returns events that are unprocessed, push-type, that belong to a configured repo" do
      expect(Event.processable).to include(unprocessed_push)
      expect(Event.processable).to_not include(processed_sync)
      expect(Event.processable).to_not include(processed_push)
    end
  end

  describe "#payload" do
    let(:event) { ci_server.events.create({ event_type: "push", json_payload: json_payload }) }

    it "returns the parsed json payload" do
      expect(event.payload).to eq(JSON.parse(json_payload))
    end
  end

end
