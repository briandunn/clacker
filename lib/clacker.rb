require 'thor'
require 'yaml'
require 'date'
require 'csv'
require 'core_ext/array'

class Clacker < Thor

  desc "[PROJECT_FILE] [DATE]", 'report about entries on the date'
  def day project_file, date
    @start = Date.parse(date)
    @stop = Date.parse(date) + 1
    @open_entries = raw_entries(project_file).map do |time, note|
      [ DateTime.parse(time).to_time, note ]
    end.select do |time, note|
      @start.to_time <= time && @stop.to_time >= time
    end
    CSV.generate do |csv|
      csv << column_names
      entries.group_by(&:project_name).map do |project, entries|
        csv << [format( '%0.2f', entries.sum(&:duration) ), project, entries.map(&:other).join("\n")]
      end
    end.tap do |report|
      puts report
    end
  end

  class Entry < Struct.new :duration, :text
    def note
      note = Note.new(text)
    end
    def project_name
      note.project_name
    end
    def other
      note.other
    end
  end

  class Note < Struct.new :text
    NAME_TAG = /(@[^\s]+)/
    def project_name
      text =~ NAME_TAG
      $1
    end
    def other
      text.gsub( NAME_TAG, '' ).strip
    end
  end

  private
  def entries
    [].tap do |entries|
      @open_entries.each_with_index do |(time, note), i|
         entries << Entry.new( hours_between( time, next_time(i) ), note )
      end
    end
  end
  def hours_between start, stop
    ( stop - start ) / 3600
  end

  def raw_file project_file
    File.read project_file
  end

  def raw_entries project_file
    YAML.load raw_file project_file
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
