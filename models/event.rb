class Event < ActiveRecord::Base
  class << self
    def unprocessed
      where(processed: false)
    end

    def pushes
      where(event_type: "push")
    end

    def with_configured_repository
      joins(:repository).merge(Repository.configured)
    end

    def processable
      unprocessed.pushes.with_configured_repository
    end
  end

  belongs_to :repository
  has_many :builds

  validate :payload

  def payload
    JSON.parse(json_payload) if json_payload.present?
  rescue
    errors.add(json_payload, "Must be a JSON string.")
  end

  def head_commit_id
    payload["head_commit"]["id"]
  end

  def branch
    payload["ref"].split("/").last
  end
end
