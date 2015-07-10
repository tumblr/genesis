require 'syslog'
require 'collins_client'
require 'facter'

module Genesis
  module Framework
    module Utils
      def self.tmp_path filename, sandbox = ""
        location = File.join(ENV['GENESIS_ROOT'], "tmp", sandbox)
        Dir.mkdir(location, 0755) unless File.directory? location
        File.join(location, filename)
      end

      @@config_cache = Hash.new
      @@collins_conn = nil
      @@facter = nil
      @@loggers = nil

      # mimicking rail's cattr_accessor
      def self.config_cache
        @@config_cache
      end

      def self.config_cache= (obj)
        @@config_cache = obj
      end

      def self.collins
        if @@collins_conn.nil?
          cfg = { :host => self.config_cache['collins']['host'], :username => self.config_cache['collins']['username'], :password => self.config_cache['collins']['password'] }
          @@collins_conn = ::Collins::Client.new(cfg)
        end

        @@collins_conn
      end

      def self.facter
        if @@facter.nil?
          @@facter = Facter.to_hash
        end

        @@facter
      end

      def self.log subsystem, message
        logline = subsystem.to_s + " :: " + message
        puts logline
        Syslog.open("genesis", Syslog::LOG_PID, Syslog::LOG_USER) unless Syslog.opened?
        Syslog.log(Syslog::LOG_INFO, logline)

        # Load external logging modules and send log to them
        if @@loggers.nil?
          @@loggers = self.config_cache[:loggers].map {|logger|
            begin
              require "logging/#{logger.downcase}"
              Logging.const_get(logger.to_sym)
            rescue LoadError
              puts "Could not load logger #{logger}"
            end
          }.compact
        end
        @@loggers.each {|logger| logger.log logline}
      end
    end
  end
end
