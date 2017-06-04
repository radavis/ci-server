class Event < ActiveRecord::Base
  class << self
    def processable
      unprocessed.pushes.with_configured_repository
    end

    def unprocessed
      where(processed: false)
    end

    def pushes
      where(event_type: "push")
    end

    def with_configured_repository
      joins(:repository).merge(Repository.configured)
    end
  end

  belongs_to :repository

  def payload
    JSON.parse(json_payload)
  end

  def head_commit_id
    payload["head_commit"]["id"]
  end
end
