require "open3"

class Builder
  class << self
    def build
      result = Database.execute("select * from builds where started = 0").first
      id = result&.[]("id")
      if id
        new(id).build
      else
        puts "Builder: no builds to build."
      end
    end
  end

  def initialize(build_id)
    @build = db.execute("select * from builds where builds.id = ?", [build_id]).first
  end

  def build
    set_build_to_started
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        execute_command_list
      end
    end
  end

  private
  attr_reader :db

  def execute_command_list
    executed_commands = []
    exitstatus = 0

    puts "builds.id: #{@build["id"]} for #{repository["name"]} started."
    command_list.each do |command|
      puts "  executing: #{command}"
      stdout, stderr, status = Open3.capture3(command)  # log this
      exitstatus = status.exitstatus
      executed_commands << [command, stdout, stderr, exitstatus]
      break if exitstatus != 0
    end

    puts "builds.id: #{@build["id"]} for #{repository["name"]} exited with #{exitstatus} exit status."
    sql = "update builds set build_report = ?, exit_status = ? where id = ?"
    db.execute(sql, [executed_commands.to_json, exitstatus, @build["id"]])
  end

  def command_list
    [
      "git init",
      "git remote add origin #{repository_url}",
      "git pull origin master",
      "git checkout #{head_commit_id}",
      configuration_instructions,
      build_instructions
    ]
  end

  def set_build_to_started
    puts "Update builds.id: #{@build["id"]} set to started for #{repository["name"]}."
    db.execute("update builds set started = 1 where id = ?", [@build["id"]])
  end

  def repository
    @repo ||= db.execute("select * from repositories where id = ?", @build["repository_id"]).first
  end

  def repository_url
    name = repository["name"]
    "https://github.com/#{name}.git"
  end

  def configuration_instructions
    repository["configuration_instructions"] || "echo 'configuration instructions not present.'"
  end

  def build_instructions
    repository["build_instructions"]
  end

  def head_commit_id
    @build["head_commit_id"]
  end

  def db
    @db ||= Database.new
  end
end
