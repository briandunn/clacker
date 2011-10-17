require 'spec_helper'
describe 'Given a file that specifies working directories for projects' do
  it_should_behave_like :a_report do
    let :yaml do
      <<-YAML
      @mulu
        ~/src/versioned/clacker
      Wed Jun 29 17:01:10 CDT 2011: @mulu
      YAML
    end
    its(:first) { should eq [ 'hours', 'project', 'notes' ] }
  end
end
