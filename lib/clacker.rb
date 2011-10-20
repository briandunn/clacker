require 'thor'
require 'yaml'
require 'date'
require 'csv'
require 'core_ext/array'
require 'grit'
require 'clacker/harvest'

module Clacker

  def self.project= project
    @@project = project
  end

  def self.project
    @@project
  end

  class CLI < Thor

    desc "[PROJECT_FILE] [DATE]", 'report about entries on the date'
    method_options harvest: :boolean
    def day project_file_path, date
      @start = Date.parse(date)
      @stop = Date.parse(date) + 1
      Clacker.project = project_file = ProjectFile.new(project_file_path)
      @open_entries = project_file.entries.map do |time, note|
        [ DateTime.parse(time).to_time, note ]
      end.select do |time, note|
        @start.to_time <= time && @stop.to_time >= time
      end
      Harvest.push entries if options['harvest']
      print_report entries
    end

    class Entry < Struct.new :time, :duration, :text

      def note
        note = Note.new(time, text)
      end

      def project_name
        note.project_name
      end

      def other
        note.other
      end
    end

    class Note < Struct.new :time, :text
      NAME_TAG = /(@[^\s]+)/
      def project_name
        text =~ NAME_TAG
        $1
      end
      def other
        text.gsub(NAME_TAG, '').strip + commit_messages
      end
      def date
        time.to_date
      end
      def commit_messages
        (commits if repo_path) || ''
      end
      def commits
        `cd #{repo_path} && git log --pretty=%s --after #{date}T00:00 --before #{date}T23:59`.chomp
      end
      def repo_path
        Clacker.project.repo_path(project_name)
      end
    end

    class ProjectFile

      attr_reader :path

      def initialize path
        @path = path
      end

      def repo_path(project)
        if project = projects[project]
          project['path']
        end
      end

      def entries
        @entries ||= data.reject { |key, value| key =~ /^@/ }
      end

      def projects
        @projects ||= data.reject { |key,value| key !~ /^@/ }
      end

      private

      def data
        @data ||= (YAML.load(File.read(path)) || {})
      end
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
