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
