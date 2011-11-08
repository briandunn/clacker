require 'nokogiri'
module Clacker
  class CLI < Thor

    desc "day [LOG_FILE_PATH] [DATE]", 'report about entries on the date'
    method_options harvest: :boolean
    def day log_file_path, date
      Clacker.log_file_path = log_file_path
      entries = entries_on Date.parse(date)
      Harvest.push entries if options['harvest']
      print_report entries
    end

    desc 'tasks', 'list harvest tasks'
    def tasks
      puts Harvest.client.tasks.to_yaml
    end

    private

    def print_report entries
      CSV.generate do |csv|
        csv << column_names
        entries.each do |entry|
          csv << [format('%0.2f', entry.duration), entry.project_name, entry.other]
        end
      end.tap do |report|
        puts report
      end
    end

    def entries_on date
      Clacker.log.entries.on(date).by_project
    end

    def column_names
      %w[hours project notes]
    end
  end
end
