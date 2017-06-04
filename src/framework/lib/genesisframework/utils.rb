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
        if config_cache.fetch(:facter_cache, true)
          if @@facter.nil?
            @@facter = Facter.to_hash
          end
          @@facter
        else
          Facter.to_hash
        end
      end

      def self.log subsystem, message, level = nil
        logline  = subsystem.to_s + " :: " + message

        # Normalize input as strings or symbols
        severity = self.log_level_from_string(level)

        # Format the output for basic STDOUT
        local_severity = severity.nil? ? 'INFO' : severity.upcase
        puts local_severity + " - " + logline

        # Load external logging modules
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

        # Send log to them
        @@loggers.each {|logger| logger.log logline, severity }
      end

      # Copied from https://github.com/tumblr/collins/blob/master/support/ruby/collins-client/lib/collins/api/logging.rb#L155
      # A private method used to validate the log level from user input
      # Each Genesis_framework logger modules will have to do a mapping from Collins_client SEVERITY to their own.
      def self.log_level_from_string level
        return nil if (level.nil? || level.empty?)
        s = Collins::Api::Logging::Severity
        if s.valid? level then
          s.value_of level
        else
          raise Collins::ExpectationFailedError.new("#{level} is not a valid log level")
        end
      end

    end
  end
end
