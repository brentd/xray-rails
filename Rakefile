#!/usr/bin/env rake
require "bundler/gem_tasks"
require "rspec/core/rake_task"

desc "Start the spec/dummy Rails app"
task "server" do
  exec "script/server"
end

desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  # TODO: uncomment this and fix warnings
  # t.ruby_opts = %w(-w)
end

task :default => [:spec]
