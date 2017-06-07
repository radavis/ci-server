class Build < ActiveRecord::Base
  class << self
    def unstarted
      where(started: false)
    end
  end

  belongs_to :repository
  has_many :events, through: :repository

  def passed?
    exit_status == 0
  end

  def failed?
    !passed
  end

  def head_commit_id
    event.head_commit_id
  end
end
