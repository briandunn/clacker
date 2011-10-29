module Clacker
    class Log

    attr_reader :data
    attr_reader :projects

    def initialize data, project_settings
      @data = data
      @projects = project_settings
    end

    def repo_path(project)
      if project = projects[project]
        project['path']
      end
    end

    def entries
      [].tap do |entries|
        data.each_with_index do |raw_entry, i|
          time, note = raw_entry.time, raw_entry.note
          duration = hours_between(time, next_time(i))
          entries << Entry.new(time, duration, note)
        end
      end
    end

    private

    def hours_between start, stop
      ( stop.to_time - start.to_time ) / 3600
    end

    def next_time i
      if entry = data[i + 1]
        entry.time
      else
        at_midnight(data.last.time)
      end
    end

    def at_midnight time
      (time.to_date + 1).to_time
    end

    def self.from_file path
      log_data = YAML.load(File.read(path)) || {}
      log_entries = log_data.map do |key, value|
        LogEntry.new(DateTime.parse(key), value) rescue next
      end.compact
      project_settings = log_data.select { |key, value| key =~ /^@/ }
      new(log_entries, project_settings)
    end

    LogEntry = Struct.new(:time, :note)
  end
end
