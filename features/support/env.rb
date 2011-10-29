require 'bundler'
Bundler.setup
Bundler.require 'test'
require 'aruba/cucumber'
require 'csv'
root = Pathname.new File.expand_path '../../..', __FILE__
$:.unshift root.join 'lib'
ENV['PATH'] = "#{root.join 'bin'}#{File::PATH_SEPARATOR}#{ENV['PATH']}"
