require 'rspec'
$:.unshift(File.join(File.dirname(File.dirname(__FILE__)),'lib')) 
require 'clacker'
describe Clacker::Entry do
  let(:project_file) do
    """
- story: 11402843
  stint: Tue Mar 22 11:09:44 CDT 2011..Tue Mar 22 11:22:53 CDT 2011
- story: 11403013
  stint: Tue Mar 22 11:22:53 CDT 2011..Tue Mar 22 12:00:53 CDT 2011
- story: 11403013
  stint: Tue Mar 22 13:26:35 CDT 2011..Tue Mar 22 17:15:16 CDT 2011
- story: 11403013
  stint: Wed Mar 23 09:24:00 CDT 2011..Wed Mar 23 10:36:06 CDT 2011
- story: 11403013
  stint: Thu Mar 24 09:18:55 CDT 2011..Thu Mar 24 09:28:36 CDT 2011
- story: 11637027
  stint: Mon Mar 28 17:50:32 CDT 2011..Mon Mar 28 18:05:32 CDT 2011
- Wed Mar 30 09:53:34 CDT 2011..Wed Mar 30 13:05:26 CDT 2011
- Wed Mar 30 21:57:16 CDT 2011..Thu Mar 31 00:23:44 CDT 2011
- Thu Mar 31 10:22:18 CDT 2011..Thu Mar 31 11:57:14 CDT 2011
- Thu Mar 31 13:47:46 CDT 2011..Thu Mar 31 15:39:27 CDT 2011
    """
  end
  context "from maped attributes" do
    let(:entry) { Clacker::Entry.parse YAML.load(project_file)[0] }
    subject { entry }
    its(:start) { should == Time.local(2011,3,22,11,9,44) }
    describe :story_ids do
      subject {entry.story_ids}
      it { should include( 11402843 ) }
      context "when the commit messages include story ids" do
        let(:commit) { double 'commit', :stories => [11402844] }
        before do
          pending
          Clacker::Project.stub :commits => [commit]
        end
        subject {entry.stories}
        its(:size) { should eq 2 }
        it { should include( 11402844 ) }
        it { should include( 11402843 ) }
      end
    end
  end
end
