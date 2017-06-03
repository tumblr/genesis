require 'syslog'

module Logging
  module Syslog
    def self.log message, level = nil

      # Tumbler Collin severity mapping:
      # - http://www.rubydoc.info/gems/collins_client/0.2.17/Collins/Api/Logging/Severity
      #
      # Compared to Syslog, Collins has an additional level 'note', for an operator input.
      # We should not come into this level via Genesis.
      # Anyway, handle it via the default level.
      priority = case level
                 when /^EMER/i
                   ::Syslog::LOG_EMERG
                 when /^ALERT/i
                   ::Syslog::LOG_ALERT
                 when /^CRIT/i
                   ::Syslog::LOG_CRIT
                 when /^ERR/i
                   ::Syslog::LOG_ERR
                 when /^WARN/i
                   ::Syslog::LOG_WARNING
                 when /^NOTICE/i
                   ::Syslog::LOG_NOTICE
                 when /^DEBUG/i
                   ::Syslog::LOG_DEBUG
                 else
                   ::Syslog::LOG_INFO
                 end

      ::Syslog.open("genesis", ::Syslog::LOG_PID, ::Syslog::LOG_USER) unless ::Syslog.opened?
      ::Syslog.log(priority, message)
    end
  end
end
