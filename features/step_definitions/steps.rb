Given 'this project file:' do |project|
  write_file 'project.yaml', project
end

When /^I clack with the arguments:$/ do |table|
  args = table.raw.first
  task = args.shift
  command = (%w[clack] + [task] + %w[project.yaml] + args).join(" ")
  When "I run `#{command}`"
end

Then /^I see this CSV:$/ do |table|
  table.diff! CSV.parse(all_stdout)
end
