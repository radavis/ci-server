ENV["RACK_ENV"] = "test"
require_relative "../server"
require "rack/test"
require "rspec"

module RackHelpers
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
end

RSpec.configure do |config|
  config.include RackHelpers

  config.backtrace_exclusion_patterns << /.gem/
  config.before(:each) { `sqlite3 #{Database.new} < ./db/schema.sql` }

  # silence stdout, stderr during testing https://stackoverflow.com/a/15432948/2675670
  standard_out = $stdout
  standard_err = $stderr

  config.before(:all) do
    $stdout = File.open(File::NULL, "w")
    $stderr = File.open(File::NULL, "w")
  end

  config.after(:all) do
    $stdout = standard_out
    $stderr = standard_err
  end

=begin
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.profile_examples = 10
=end

  config.order = :random
  Kernel.srand config.seed
end
