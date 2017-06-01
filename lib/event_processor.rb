class EventProcessor
  class << self
    def unprocessed_events
      sql = <<-SQL
        select * from events
        join repositories on events.repository_id = repositories.id
        where repositories.build_instructions not null and
          events.event_type like 'push' and
          events.processed = 0;
      SQL

      Database.execute(sql)
    end

    def engage
      unprocessed_events.each do |event|
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

        db = Database.new
        db.transaction
        db.execute(insert_build, build_values)
        db.execute(update_event, event_values)
        db.commit
      end
    end
  end
end

<<-NOTES
  Processes GitHub event records into build records.
NOTES
