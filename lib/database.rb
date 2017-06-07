require "sqlite3"

class Database < SQLite3::Database
  class << self
    def execute(*args)
      new.execute(*args)
    end

    def config
      {
        adapter: "sqlite3",
        database: name
      }
    end

    def name
      env = ENV["RACK_ENV"] || "development"
      return ":memory:" if env == "production"
      return File.join(".", "db", "ci-server-#{env}.db")
    end
  end

  attr_reader :name

  def initialize(name = nil)
    @name = name || self.class.name
    super(@name)
    @results_as_hash = true
  end

  def to_s
    self.class.name
  end
end
