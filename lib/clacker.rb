require 'thor'
require 'git'
require 'pivotal-tracker'
require 'date'
require 'csv'
require 'forwardable'
require 'core_ext/array'

class Clacker < Thor
  autoload :Entry, 'clacker/entry'
  autoload :Project, 'clacker/project'

  desc "report [PROJECT_FILE]", "print a CSV report"
  def report(project_file, start_date, end_date)
    start_date, end_date = [start_date, end_date].map {|date| Date.parse(date) }
    Project.file = project_file
    grouped = (Project.entries.group_by do |range|
      range.date
    end).delete_if do |key, value|
      not ( start_date..( end_date + 1 ) ).cover?(key)
    end
    report = CSV.generate do |csv|
      csv << column_names
      for day, entries in grouped
        row = Row.new(entries)
        csv << row.to_column_values( *column_names )
      end
    end
    puts report
  end
 
  private
  def column_names
    %w[date hours notes commits].tap do |cols| 
      cols << 'stories' if Project.pivotal?
    end
  end
end
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
