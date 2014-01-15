require 'log4r/outputter/outputter'
require 'log4r/staticlogger'
require 'logglier'

module Log4r

  class LogglierOutputter < Outputter
    attr_reader :host, :port
     
    def initialize(_name, hash={})
      super(_name, hash)
      @host = (hash[:hostname] or hash['hostname'])
      @port = (hash[:port] or hash['port'])

      begin 
        Logger.log_internal {
          "LogglierOutputter will send to #{@host}:#{@port}"
        }
        @logger = Logglier.new("udp://#{host}:#{port}/16")
      rescue Exception => e
        Logger.log_internal(ERROR) {
          "LogglierOutputter failed to create log instance: #{e}"
        }
        Logger.log_internal {e}
        self.level = OFF
      raise e
      end
    end

    #######
    private
    #######

    def canonical_log(logevent)
      @logger.send(LNAMES[logevent.level].downcase, format(logevent))
    rescue Exception => e
      Logger.log_internal(ERROR) {
        "LogglierOutputter failed to send data to #{@host}:#{@port}, #{e}"
      }
    end
    
  end

end
