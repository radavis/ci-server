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
    if ENV["RACK_ENV"] == "test"
      return "./db/ci-server-test.db"
    elsif ENV["RACK_ENV"] == "production"
      return "./db/ci-server-production.db"
    else # default to development
      return "./db/ci-server-development.db"
    end
  end
end
