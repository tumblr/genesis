require 'syslog'

module Logging
  module Syslog
    def self.log message
      ::Syslog.open("genesis", ::Syslog::LOG_PID, ::Syslog::LOG_USER) unless ::Syslog.opened?
      ::Syslog.log(::Syslog::LOG_INFO, message)
    end
  end
end
