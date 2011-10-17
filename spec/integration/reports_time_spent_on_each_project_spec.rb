require 'spec_helper'
describe 'Given a time file with zero entries on the given day' do
  it_should_behave_like :a_report do
    let(:yaml) { '' }
    it { should eq [[ 'hours', 'project', 'notes' ]] }
  end
end

describe 'Given a time file with one entry on the given day' do
  it_should_behave_like :a_report do
    let :yaml do
      'Fri Jun 24 17:30:00 CDT 2011: @off outie'
    end
    it do
      should eq [
        [ 'hours', 'project', 'notes' ],
        [ '6.50' , '@off'   , 'outie' ]
      ]
    end
  end
end
describe 'Given a time file with multiple project tags', focus: true do
  it_should_behave_like :a_report do
    let :yaml do
      <<-YAML
        Fri Jun 24 09:00:00 CDT 2011: @internal standup
        Fri Jun 24 09:05:00 CDT 2011: @mulu-demo
        Fri Jun 24 11:25:00 CDT 2011: @off lunch
        Fri Jun 24 12:25:00 CDT 2011: @mulu
        Fri Jun 24 17:25:00 CDT 2011: @off outie
      YAML
    end
    it do 
      should eq [
        [ 'hours', 'project'   , 'notes'   ],
        [ '0.08' , '@internal' , 'standup' ],
        [ '2.33' , '@mulu-demo', ''        ],
        [ '7.58' , '@off'      , "lunch\noutie"   ],
        [ '5.00' , '@mulu'     , ''        ]
      ]
    end
  end
end
