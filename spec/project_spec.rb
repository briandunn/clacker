require 'spec_helper'
describe Clacker::Project do
  describe '.entries' do
    context "with entries that have implicit stints" do 
      let :file do
        double read: <<-YAML
          entries:
            Mon Jun 20 09:20:31 CDT 2011: worked on @clacker
            Mon Jun 20 09:30:00 CDT 2011: High fived myself and went home
        YAML
      end
      before do
        Pathname.should_receive(:new).with(:foo).and_return(file)
        Clacker::Project.file = :foo
      end
      let( :entries ) { Clacker::Project.entries }
      subject { entries }
      its(:size) { should eq 2 }
      describe "the first entry" do
        subject { entries.first }
        its(:stint) {should eq Date.parse('Mon Jun 21 09:20:31 CDT 2011')..Date.parse('Mon Jun 20 09:30:00 CDT 2011') }
      end
      describe "the last entry" do
        subject { entries.last }
        its(:stint) {should eq Date.parse('Mon Jun 20 09:30:00 CDT 2011')..Date.parse('Mon Jun 20 09:30:00 CDT 2011') }
      end
    end
  end
end
