module Clacker
    class Log

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
