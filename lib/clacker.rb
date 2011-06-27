require 'thor'
require 'yaml'
require 'date'
require 'csv'
require 'core_ext/array'

class Clacker < Thor

  desc "[PROJECT_FILE] [DATE]", 'report about entries on the date'
  def day project_file, date
    @stop = Date.parse(date) + 1
    @entries = raw_entries(project_file).map do |time, note|
      [ DateTime.parse(time).to_time, note ]
    end
    CSV.generate do |csv|
      csv << column_names
      @entries.each_with_index do |(time, note), i|
        note = Note.new(note)
        csv << [hours_between( time, next_time(i) ), note.project_name, note.other ]
      end
    end.tap do |report|
      puts report
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
  def hours_between start, stop
    format '%0.2f', ( stop - start ) / 3600
  end

  def raw_file project_file
    File.read project_file
  end

  def raw_entries project_file
    YAML.load raw_file project_file
  end

  def next_time i
    if entry = @entries[i + 1]
      entry.first
    else
     @stop.to_time
    end
  end
 
  def column_names
    %w[hours project notes]
  end
end
=begin
class Clacker
  class Row < Struct.new :entries
    def to_column_values *columns
      columns.map do |col|
        send col
      end
    end
    def hours
      sprintf '%0.2f', duration
    end
    def date
      @day ||= entries.map( &:date ).sort.first
    end
    def commit_messages
      @commit_messages ||= Project.commits(
        Range.new entries.map(&:start).min, entries.map(&:stop).max
      ).map(&:message).join("\n")
    end
    def commits; commit_messages; end
    def notes
      entries.map(&:notes).join("\n")
    end
    def duration 
      entries.sum &:duration
    end
    def story_names
      Note.new(commit_messages + notes)
        .stories.map(&:name).join("\n")
    end
    def stories; story_names; end
  end
  class Note < Struct.new :text
    def stories
      story_ids.uniq.map do |id|
        self.class.project.stories.find(id)
      end
    end
    def story_ids
      [].tap do |ids|
        text.scan /\[([^\]]*)\]/ do
          $1.scan /#(\d+)/ do
            ids << $1.to_i
          end
        end
      end
    end
    class << self
      def project
        @project ||= PivotalTracker::Project.find(Project.pivotal_id) 
      end
    end
  end
end
=end
