require "open3"
require "pp"

class Builder
  class << self
    def build
      result = Build.unstarted.first
      if result
        new(result).build
      else
        puts "Builder: no builds to build."
      end
    end
  end

  attr_reader :exitstatus

  def initialize(build)
    @build = build
    @exitstatus = 0
  end

  def build
    @build.update_attributes(started: true)
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
    result = nil

    puts "builds.id: #{@build.id} for #{@build.repository.name} started."
    command_list.each do |command|
      puts "  executing: #{command}"
      stdout, stderr, status = Open3.capture3(command)
      result = status.exitstatus
      executed_commands << [command, stdout, stderr, result]
      break if result != 0
    end

    pp executed_commands
    puts "builds.id: #{@build.id} for #{@build.repository.name} exited with #{result} exit status."
    @build.update_attributes({ build_report: executed_commands.to_json, exit_status: result })
  end

  def command_list
    [
      "git init",
      "git remote add origin #{@build.repository.url}",
      "git pull origin master",
      "git fetch",
      "git checkout #{@build.event.branch}",
      @build.repository.instructions
    ].flatten
  end
end
