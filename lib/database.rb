require "sqlite3"

class Database
  attr_reader :name

  def initialize(name = nil)
    @name = name || name_from_env
    @db = SQLite3::Database.new(@name)
  end

  def execute(*sql)
    @db.execute(*sql)
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
