# encoding: utf-8
require 'rubygems'
require 'bundler'
Bundler.setup

require 'cucumber/rake/task'
require "rspec/core/rake_task"

desc "Run those specs"
RSpec::Core::RakeTask.new :spec do |t|
  t.rspec_opts = %w{--colour --format progress}
  t.pattern = 'spec/**/*_spec.rb'
end

Cucumber::Rake::Task.new :cucumber

task :default => [:spec, :cucumber]
