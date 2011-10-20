module Clacker
  class CLI < Thor

    desc "[LOG_FILE_PATH] [DATE]", 'report about entries on the date'
    method_options harvest: :boolean
    def day log_file_path, date
      @start = Date.parse(date)
      @stop = Date.parse(date) + 1
      Clacker.log = log = Log.new(log_file_path)
      @open_entries = log.entries.map do |time, note|
        [ DateTime.parse(time).to_time, note ]
      end.select do |time, note|
        @start.to_time <= time && @stop.to_time >= time
      end
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

    def entries
      [].tap do |entries|
        @open_entries.each_with_index do |(time, note), i|
        entries << Entry.new(time, hours_between(time, next_time(i)), note)
        end
      end
    end
    def hours_between start, stop
      ( stop - start ) / 3600
    end

    def next_time i
      if entry = @open_entries[i + 1]
        entry.first
      else
        @stop.to_time
      end
    end

    def column_names
      %w[hours project notes]
    end
  end
end
