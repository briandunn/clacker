PivotalTracker::Client.tap do |client| 
  client.token = '9a156594c8316471e5abfb240c445619' #old account
#  client.token = '59938a5e8326c3751da128eaf945ad93' #google account (wti)
  client.use_ssl = true
end
class Clacker
  class Project
    class << self
      def commits date_range
        git = Git.open working_dir
        git.log
          .since(date_range.min.to_s)
          .until(date_range.max.to_s)
          .author(author)
      end
      def working_dir
        File.expand_path '~/src/mobicentric'
      end
      def author
        'Brian Dunn'
      end
      def pivotal_project_id
        30500
      end
    end
  end
end
