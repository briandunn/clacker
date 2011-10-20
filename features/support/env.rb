require 'aruba/cucumber'
require 'bundler'
Bundler.require 'test'
require 'csv'
root = Pathname.new File.expand_path '../../..', __FILE__
$:.unshift root.join 'lib'
ENV['PATH'] = "#{root.join 'bin'}#{File::PATH_SEPARATOR}#{ENV['PATH']}"
