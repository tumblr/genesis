module Logging
  module Collins

    def self.collins
      Genesis::Framework::Utils.collins
    end

    def self.facter
      Genesis::Framework::Utils.facter
    end

    def self.log message, level = nil
      if facter['asset_tag']
        collins.log! facter['asset_tag'], message, level
      end
    end
  end
end
