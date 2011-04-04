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
  def report(project_file)
    Project.file = project_file
    grouped = Project.entries.group_by do |range|
      range.date
    end
    report = CSV.generate do |csv|
      csv << %w[date hours notes commmits stories]
      for day, entries in grouped
        row = Row.new(entries)
        csv << [
          day,
          sprintf('%0.2f', row.duration),
          row.notes,
          row.commit_messages,
          row.story_names
        ]
      end
    end
    puts report
  end
end
class Clacker
  class Row < Struct.new :entries
    def commit_messages
      @commit_messages ||= Project.commits(
        Range.new entries.map(&:start).min, entries.map(&:stop).max
      ).map(&:message).join("\n")
    end
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
