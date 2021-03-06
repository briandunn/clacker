require 'net/http'
module Clacker
  class Harvest
    def initialize subdomain, email, password
      @subdomain, @email, @password = subdomain, email, password
    end

    def daily date
      get "/daily/#{date.yday}/#{date.year}"
    end

    def add_entry entry
      post "/daily/add", entry.to_xml
    end

    def tasks
      doc = Nokogiri daily(Date.today).body
      doc.xpath('//task').map do |task|
        {
          "#{task.xpath '../../name/text()'} - #{task.xpath './name/text()'}" =>
          {
            project_id: task.xpath('../../id/text()').to_s.to_i,
            task_id: task.xpath('./id/text()').to_s.to_i
          }
        }
      end
    end

    def who_am_i
      get '/account/who_am_i'
    end

    private

    def get path
      start_http do |http|
        http.request(Net::HTTP::Get.new(path, headers).tap do |req|
          req.basic_auth @email, @password
        end)
      end
    end

    def post path, body
      start_http do |http|
        http.request(Net::HTTP::Post.new(path, headers).tap do |req|
          req.basic_auth @email, @password
          req.body = body
        end)
      end
    end

    def start_http &block
      Net::HTTP.start(url, use_ssl: true, &block)
    end

    def url
      @url ||= "#@subdomain.harvestapp.com"
    end

    def headers
      @headers ||= { 'Accept' => 'application/xml', 'Content-Type' => 'application/xml' }
    end

    def self.client
      args = YAML.load_file File.expand_path '~/.harvest.yaml'
      new *args
    end

    def self.push entries
      harvest_entries = entries.map do |clack|
        if harvest_settings = clack.project_settings['harvest']
          Entry.new.tap do |harvest|
            harvest.notes      = clack.other
            harvest.hours      = clack.duration
            harvest.project_id = harvest_settings['project_id']
            harvest.task_id    = harvest_settings['task_id']
            harvest.spent_at   = clack.date
          end
        end
      end.compact
      harvest_entries.map do |entry|
        client.add_entry entry
      end
    end

    class Entry
      attr_writer :notes, :hours, :project_id, :task_id, :spent_at

      def to_xml
        return <<-XML
<request>
  <notes>#@notes</notes>
  <hours>#@hours</hours>
  <project_id type="integer">#@project_id</project_id>
  <task_id type="integer">#@task_id</task_id>
  <spent_at type="date">#@spent_at</spent_at>
</request>
        XML
      end

    end
  end
end
