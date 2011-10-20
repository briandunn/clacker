require 'thor'
require 'yaml'
require 'date'
require 'csv'
require 'core_ext/array'
require 'clacker/harvest'

module Clacker
  autoload :CLI, 'clacker/cli'

  def self.project= project
    @@project = project
  end

  def self.project
    @@project
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

    def project_settings
      Clacker.project.projects[project_name]
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

end
