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

      # Default
      if (level.nil? || level.empty?)
        severity = ::Syslog::LOG_INFO
      else
        severity = case level.downcase.to_sym
                   when :emergency
                     ::Syslog::LOG_EMERG
                   when :alert
                     ::Syslog::LOG_ALERT
                   when :critical
                     ::Syslog::LOG_CRIT
                   when :error
                     ::Syslog::LOG_ERR
                   when :error
                     ::Syslog::LOG_WARNING
                   when :notice
                     ::Syslog::LOG_NOTICE
                   when :debug
                     ::Syslog::LOG_DEBUG
                   else
                     ::Syslog::LOG_INFO
                   end
      end

      ::Syslog.open("genesis", ::Syslog::LOG_PID, ::Syslog::LOG_USER) unless ::Syslog.opened?
      ::Syslog.log(severity, message)
    end
  end
end
