class Clacker
  class Entry
    attr_accessor :notes
    def initialize(stint, notes='')
      @stint = stint 
      @notes = notes
    end
    def duration
      (@stint.last - start) / 3600.0
    end
    def start
      @stint.min
    end
    def stop
      @stint.max
    end
    def date
      start.to_date
    end
    class << self
      def parse *args
        if ( opts = args.pop ).kind_of? Hash
          new parse_stint(opts.keys.first), opts.values.first
        else
          new parse_stint(opts)
        end
      end
      private
      def parse_stint(string)
        start, stop = string.split('-').map do |date|
          DateTime.parse(date).to_time
        end
        start..stop
      end
    end
  end
  class EntryCollection < Array
    def initializer entries 
      self << entries
    end
    def stories

    end
    def duration
    end
  end
end
