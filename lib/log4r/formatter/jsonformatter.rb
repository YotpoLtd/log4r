require 'log4r/formatter/formatter'

module Log4r

  class JSONFormatter < BasicFormatter

    def initialize(hash = {})
      super(hash)
      @instance = (hash['instance'] || hash[:instance] || nil)
    end

    def format(logevent)
      logger = logevent.fullname.gsub('::', '.')
      timestamp = (Time.now.to_f * 1000).to_i
      level = LNAMES[logevent.level]
      message = format_object(logevent.data)
      file, line, method = parse_caller(logevent.tracer[0]) if logevent.tracer

      data = {
          logger: logger,
          timestamp: timestamp,
          instance: @instance,
          process: Process.pid.to_s,
          level: level,
          message: message
      }

      JSON.dump(data)
    end

    #######
    private
    #######

    def parse_caller(line)
      if /^(.+?):(\d+)(?::in `(.*)')?/ =~ line
        file = Regexp.last_match[1]
        line = Regexp.last_match[2].to_i
        method = Regexp.last_match[3]
        [file, line, method]
      else
        []
      end
    end
  end

end