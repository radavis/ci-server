class EventProcessor
  class << self
    def engage
      puts "EventProcessor: no events to process" if Event.processable.empty?
      Event.processable.each do |event|
        process(event)
      end
    end

    def process(event)
      ActiveRecord::Base.transaction do
        event.builds.create
        event.update_attributes(processed: true)
      end
    end
  end
end

<<-NOTES
  Creates build records from GitHub events.
NOTES
