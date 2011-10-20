$:.unshift(File.join(File.dirname(File.dirname(__FILE__)),'lib')) 
require 'rspec'
require 'clacker'
shared_examples_for :a_report do
  let :time_file do
    Tempfile.new( 'time_file' ).tap do |time_file|
      time_file << yaml
      time_file.close
    end
  end
  let( :report ) do
    Clacker::CLI.new.tap do |clacker|
      clacker.should_receive :puts
    end.day time_file.path, '2011-06-24'
  end
  subject { CSV.parse report }
  after do
    time_file.close!
  end
end
