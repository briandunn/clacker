require 'net/http'
require 'clacker/harvest'

Given 'this project file:' do |project|
  write_file 'project.yaml', project
end

When /^I clack with the arguments:$/ do |table|
  args = table.raw.first
  task = args.shift
  @date = Date.parse args.first
  command = (%w[clack] + [task] + %w[project.yaml] + args).join(" ")
  When "I run `#{command}`"
end

When /^I run `day` with today's date$/ do
  When "I run `clack day project.yaml #{Date.today}`"
end

Then /^I see this CSV:$/ do |table|
  table.diff! CSV.parse(all_stdout)
end


Given /^a git repo at (.+)$/ do |path|
  in_current_dir do
    @repo = Grit::Repo.init(path)
  end
end

Given /^that repo has the following commit:$/ do |table|
  in_current_dir do
    readme_path = Pathname.new(@repo.working_dir).join 'README'
    FileUtils.touch readme_path
    @repo.add readme_path
    @repo.commit_index table.rows_hash['message']
  end
end

Then /^harvest has the following entry:$/ do |table|
  entries = Nokogiri(Clacker::Harvest.client.daily(@date).body).xpath('//day_entry').map do |entry|
    ['spent at', 'project', 'task', 'hours', 'notes'].inject({}) do |h, k|
      h.tap { h[k] = entry.xpath("./#{k.gsub /\s/, '_'}/text()").to_s }
    end
  end

  table.transpose.diff! entries, surplus_row: false

end
