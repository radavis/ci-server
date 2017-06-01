class EventProcessor
  class << self
    def events
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
      events.each do |event|
        # event = Database.execute("select * from events where id = ?", event["id"])
        repository = Database.execute("select * from repositories where id = ?", event["repository_id"])

      end
    end
  end
end

<<-NOTES
  Processes event records into build records
NOTES
