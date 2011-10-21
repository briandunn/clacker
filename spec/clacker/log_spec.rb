require 'spec_helper'
describe Clacker::Log do
  describe "#entries" do
    subject { Clacker::Log.new(raw, {}).entries }
    context 'with two raw entries' do
      let :raw do
        [
          stub(time: Time.new(2011, 10, 20, 7, 45, 0, "-05:00"), note: '@foo'),
          stub(time: Time.new(2011, 10, 20, 8,  0, 0, "-05:00"), note: '@off')
        ]
      end
      it { should have(2).entries }
      it 'sets the duration of the first to the distance between the two' do
        subject.first.duration.should == 0.25
      end
      it 'sets the duration of the last to the distance between it and midnight' do
        subject.last.duration.should == 16
      end
    end

  end
end
