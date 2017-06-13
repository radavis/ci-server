class Build < ActiveRecord::Base
  class << self
    def unstarted
      where(started: false)
    end
  end

  belongs_to :event

  def repository
    event.repository
  end

  def passed?
    exit_status == 0
  end

  def failed?
    !passed
  end

  def head_commit_id
    event.head_commit_id
  end

  def to_s
    "#{head_commit_id} #{repository.name} #{passed? ? 'passed' : 'failed'} at #{updated_at}"
  end
end
