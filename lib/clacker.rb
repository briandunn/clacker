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
    grouped = ranges(project_file).group_by do |range|
      range.date
    end
    report = CSV.generate do |csv|
      csv << %w[date hours notes commmits stories]
      for day, entries in grouped
        commit_messages = Project.commits(
            Range.new entries.map(&:start).min, entries.map(&:stop).max
        ).map(&:message).join("\n")
        notes = entries.map(&:notes).join("\n")
        story_names = Note.new(commit_messages + notes)
          .stories.map(&:name).join("\n")
        csv << [
          day,
          entries.sum(&:duration),
          notes,
          commit_messages,
          story_names
        ]
      end
    end
    puts report
  end
  private
  def ranges(project_file) 
    YAML.load(Pathname.new( project_file ).read).map do |entry_row|
      Entry.parse entry_row 
    end
  end
end
class Clacker
  class Note 
    attr_accessor :text
    def initialize text
      @text = text
    end
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
        @project ||= PivotalTracker::Project.find(Project.pivotal_project_id) 
      end
    end
  end
end
