require "open3"

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
    build.update_attributes(started: true)
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

    puts "builds.id: #{@build.id} for #{@build.repository.name} started."
    command_list.each do |command|
      puts "  executing: #{command}"
      stdout, stderr, status = Open3.capture3(command)
      exitstatus = status.exitstatus
      executed_commands << [command, stdout, stderr, exitstatus]
      break if exitstatus != 0
    end

    puts "builds.id: #{@build.id} for #{@build.repository.name} exited with #{exitstatus} exit status."
    @build.update_attributes({ build_report: executed_commands.to_json, exit_status: exitstatus })
  end

  def command_list
    [
      "git init",
      "git remote add origin #{@build.repository.url}",
      "git pull origin master",
      "git checkout #{@build.head_commit_id}",
      @build.configuration_instructions,
      @build.build_instructions
    ]
  end
end
