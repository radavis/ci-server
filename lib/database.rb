require "sqlite3"

class Database < SQLite3::Database
  class << self
    def execute(*args)
      new.execute(*args)
    end
  end

  attr_reader :name

  def initialize(name = nil)
    @name = name || name_from_env
    super(@name)
    @results_as_hash = true
  end

  def to_s
    name
  end

  private

  def name_from_env
    env = ENV["RACK_ENV"] || "development"
    return "./db/ci-server-#{env}.db"
  end
end
