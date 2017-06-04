class EventProcessor
  class << self
    def unprocessed_events
      sql = <<-SQL
        select * from events
        join repositories on events.repository_id = repositories.id
        where repositories.url not null and
          repositories.build_instructions not null and
          events.processed = 0 and
          events.event_type like 'push';
      SQL

      Database.execute(sql)
    end

    def engage
      puts "EventProcessor: no events to process" if unprocessed_events.empty?
      unprocessed_events.each do |event|
        process(event)
      end
    end

    def process(event)
      head_commit_id = JSON.parse(event["json_payload"])["head_commit"]["id"]
      repository = Database.execute("select * from repositories where id = ?", event["repository_id"]).first

      insert_build = <<-SQL
        insert into builds (head_commit_id, repository_id, created_at, updated_at)
        values (?, ?, ?, ?)
      SQL
      build_values = [head_commit_id, repository["id"], Time.now.to_i, Time.now.to_i]

      update_event = <<-SQL
        update events set processed = ?, updated_at = ?
        where id = ?
      SQL
      event_values = [1, Time.now.to_i, event["id"]]

      puts "Transaction start."
      puts "  Updating repositories.name: #{repository["name"]} with head_commit_id: #{head_commit_id}."
      puts "  Creating new builds record."
      db = Database.new
      db.transaction
      db.execute(insert_build, build_values)
      build_id = db.last_insert_row_id
      db.execute(update_event, event_values)
      db.commit
      puts "  builds.id: #{build_id} created."
      puts "Transaction end."
    rescue SQLite3::Exception => e
      puts "Transaction failed."
      puts e
      db.rollback
    end
  end
end

<<-NOTES
  Processes GitHub event records into build records.
NOTES
