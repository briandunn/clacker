require 'thor'
require 'yaml'
require 'date'
require 'csv'
require 'core_ext/array'
require 'clacker/harvest'

module Clacker
  autoload :CLI, 'clacker/cli'
  autoload :Log, 'clacker/log'

  def self.log_file_path= log_file_path
    @@log = Log.from_file log_file_path
  end

  def self.log
    @@log
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
      Clacker.log.projects[project_name] || {}
    end

    def + entry
      self.class.new time, duration + entry.duration, "#{text}\n#{entry.text}"
    end

    def date
      time.to_date
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
      Clacker.log.repo_path(project_name)
    end
  end

end
