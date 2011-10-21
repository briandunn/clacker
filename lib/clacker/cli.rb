module Clacker
  class CLI < Thor

    desc "[LOG_FILE_PATH] [DATE]", 'report about entries on the date'
    method_options harvest: :boolean
    def day log_file_path, date
      Clacker.log_file_path = log_file_path
      entries = entries_on Date.parse(date)
      Harvest.push entries if options['harvest']
      print_report entries
    end

    private

    def print_report entries
      CSV.generate do |csv|
        csv << column_names
        entries.group_by(&:project_name).map do |project, entries|
          csv << [format( '%0.2f', entries.sum(&:duration) ), project, entries.map(&:other).uniq.join("\n")]
        end
      end.tap do |report|
        puts report
      end
    end

    def entries_on date
      Clacker.log.entries.select do |entry|
        entry.time.to_date == date.to_date
      end
    end

    def column_names
      %w[hours project notes]
    end
  end
end
