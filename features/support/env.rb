require 'aruba/cucumber'
require 'bundler'
Bundler.require
require 'csv'
ENV['PATH'] = "#{File.expand_path(File.dirname(__FILE__) + '/../../bin')}#{File::PATH_SEPARATOR}#{ENV['PATH']}"
