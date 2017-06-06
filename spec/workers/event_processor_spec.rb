RSpec.describe EventProcessor do
  describe ".engage" do
    let(:db) { Database.new }
    let(:now) { Time.now.to_i }
    let(:url) { "https://radavis:token@github.com/radavis/ci-server" }
    let(:build_instructions) { "rake spec" }
    let(:json_payload) { File.read("./docs/github-push-event.json") }
    let(:event) { JSON.parse(json_payload) }

    context "repository has a url and build instructions" do
      it "marks the event as processed" do
        event_id = create_repository_and_event_returning_event_id(url, build_instructions)
        EventProcessor.engage
        event = db.execute("select * from events where id = ?", [event_id]).first
        expect(event["processed"]).to eq(1)
      end

      it "increases the number of build records by one" do
        initial_count = db.execute("select * from builds").size
        event_id = create_repository_and_event_returning_event_id(url, build_instructions)
        EventProcessor.engage
        count = db.execute("select * from builds").size
        expect(count).to eq(initial_count + 1)
      end
    end

    context "repository without a url" do
      it "does not process events without build instructions" do
        event_id = db.last_insert_row_id
        event_id = create_repository_and_event_returning_event_id(nil, build_instructions)
        EventProcessor.engage
        event = db.execute("select * from events where id = ?", [event_id]).first
        expect(event["processed"]).to eq(0)
      end

      it "doesn't create a build record" do
        initial_count = db.execute("select * from builds").size
        event_id = create_repository_and_event_returning_event_id(nil, build_instructions)
        EventProcessor.engage
        count = db.execute("select * from builds").size
        expect(count).to eq(initial_count)
      end
    end

    context "repository without build instructions" do
      it "does not process events without build instructions" do
        event_id = db.last_insert_row_id
        event_id = create_repository_and_event_returning_event_id(url, nil)
        EventProcessor.engage
        event = db.execute("select * from events where id = ?", [event_id]).first
        expect(event["processed"]).to eq(0)
      end

      it "doesn't create a build record" do
        initial_count = db.execute("select * from builds").size
        event_id = create_repository_and_event_returning_event_id(url, nil)
        EventProcessor.engage
        count = db.execute("select * from builds").size
        expect(count).to eq(initial_count)
      end
    end
  end
end

def create_repository_and_event_returning_event_id(url, build_instructions)
  name = event["repository"]["full_name"]
  sql = "insert into repositories (name, url, build_instructions, created_at, updated_at) values (?, ?, ?, ?, ?)"
  values = [name, url, build_instructions, now, now]
  db.execute(sql, values)
  repository_id = db.last_insert_row_id

  sql = "insert into events (repository_id, event_type, json_payload, created_at, updated_at) values (?, ?, ?, ?, ?)"
  db.execute(sql, [repository_id, "push", json_payload, now, now])
  db.last_insert_row_id
end
