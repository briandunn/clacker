require 'vcr'

VCR.config do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.stub_with :webmock
  c.default_cassette_options = { record: :new_episodes, match_requests_on: [:uri, :method, :body] }
end

Around do |scenario, block|
  VCR.use_cassette('default') { block.call }
end
