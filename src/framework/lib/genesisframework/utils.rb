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

        # Format the output on basic STDOUT
        severity = level.nil? ? 'INFO' : level
        puts severity + " - " + logline

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

        @@loggers.each {|logger| logger.log logline, level }
      end
    end
  end
end
