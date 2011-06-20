class Clacker
  class Project
    class << self

      attr_reader :file

      def file= file
        @file = YAML.load Pathname.new(file).read
        @file['pivotal']['token'].tap do |token|
          PivotalTracker::Client.token = token
        end if pivotal?
      end

      def commits date_range
        git = Git.open working_dir
        git.log
          .since(date_range.min.to_s)
          .until(date_range.max.to_s)
          #.author(author)
      end
      def working_dir
        File.expand_path file['working_dir']
      end
      def author
        'Brian Dunn'
      end
      def pivotal_id
        file['pivotal']['project_id'] if pivotal?
      end
      def pivotal?
        !file['pivotal'].nil?
      end
      def entries 
        last_stint, last_note = nil
        entries = []
        file['entries'].each do |entry_row|
          if last_stint
            end_of_last_stint = Stint.new( entry_row.first ).start
            entries << Entry.new( last_stint.start..end_of_last_stint, last_note )
          end
          last_stint = Stint.new( entry_row.first )
          last_note = entry_row.last
        end
        entries
      end
    end
  end
  class Stint
    attr_accessor :start, :stop
    def initialize string
      parse_stint(string)
    end
    def to_range
      start..stop
    end
    def parse_stint(string)
      if string =~ / - /
        self.start, self.stop = string.split(' - ').map do |date|
          DateTime.parse(date).to_time
        end
      else
        self.start = DateTime.parse(string).to_time
      end
    end
  end
end
