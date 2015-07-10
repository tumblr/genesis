module Logging
  module Collins

    def self.collins
      Genesis::Framework::Utils.collins
    end

    def self.facter
      Genesis::Framework::Utils.facter
    end

    def self.log message
      if self.facter['asset_tag']
        collins.log! 'tumblrtag301', message
      end
    end
  end
end
