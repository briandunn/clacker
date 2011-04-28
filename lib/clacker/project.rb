class Clacker
  class Project
    class << self

      attr_reader :file

      def file= file
        @file = YAML.load( Pathname.new(file).read ).tap do |config|
          config['pivotal']['token'].tap do |token|
            PivotalTracker::Client.token = token
          end
        end
      end

      def commits date_range
        git = Git.open working_dir
        git.log
          .since(date_range.min.to_s)
          .until(date_range.max.to_s)
          .author(author)
      end
      def working_dir
        File.expand_path file['working_dir']
      end
      def author
        'Brian Dunn'
      end
      def pivotal_id
        file['pivotal']['project_id']
      end
      def entries 
        file['entries'].map do |entry_row|
          Entry.parse entry_row 
        end
      end
    end
  end
end
