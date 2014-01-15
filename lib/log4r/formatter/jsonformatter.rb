require 'log4r/formatter/formatter'

module Log4r

  class JSONFormatter < BasicFormatter

    def format(logevent)
      logger = logevent.fullname.gsub('::', '.')
      timestamp = (Time.now.to_f * 1000).to_i
      level = LNAMES[logevent.level]
      message = format_object(logevent.data)
      exception = message if logevent.data.kind_of? Exception
      file, line, method = parse_caller(logevent.tracer[0]) if logevent.tracer

      data = {
          logger: logger,
          timestamp: timestamp,
          level: level,
          thread: {
              NDC: NDC.get,
              message: message,
              throwable: exception,
              location_info: {
                  method: method,
                  file: file,
                  line: line
              }
          }
      }
      MDC.get_context.each do |key, value|
        (data[:thread][:properties] ||= {})[key] = value
      end

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