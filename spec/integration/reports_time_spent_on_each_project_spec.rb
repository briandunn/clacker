require 'spec_helper'
describe 'Given a time file with zero entries on the given day' do
  it_should_behave_like :a_report do
    let(:yaml) { '' }
    it { should eq [[ 'hours', 'project', 'notes' ]] }
  end
end
