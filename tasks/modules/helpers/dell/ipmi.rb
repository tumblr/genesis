module Helpers
  module Dell
    class IPMI

      RESET_DELAY = 15

      def self.log message 
        Genesis::Framework::Utils.log "Helpers::Dell::IPMI", message 
      end

      def self.configure_bmc_ipmi(asset)
        %W{
          Lan_Conf:IP_Address_Source=Static
          Lan_Conf:IP_Address=#{asset.ipmi.address}
          Lan_Conf:Subnet_Mask=#{asset.ipmi.netmask}
          Lan_Conf:Default_Gateway_IP_Address=#{asset.ipmi.gateway}
          Lan_Channel:Volatile_Access_Mode=Always_Available
          Lan_Channel:Non_Volatile_Access_Mode=Always_Available
          User1:Password=#{asset.ipmi.password}
          User2:Password=#{asset.ipmi.password}
        }.map do |conf|
          self.log "Setting BMC #{conf}"
          Kernel.system("/usr/sbin/bmc-config -c -e '#{conf}'")
        end.all?
      end

      def self.verify_bmc_ipmi(asset)
        {
          'IP_Address'                 => asset.ipmi.address,
          'Subnet_Mask'                => asset.ipmi.netmask,
          'Default_Gateway_IP_Address' => asset.ipmi.gateway
        }.map do |attr,conf|
          output = %x{/usr/sbin/bmc-config -o -e 'Lan_Conf:#{attr}'}
          line = output.lines.grep(/^[\s]*#{attr}/).first
          if line.nil?
            self.log "Error: Unable to find #{attr}" if line.nil?
            false
          else
            begin
              val = line.split(/\s+/)[2]
              comp = val == conf
              self.log "Error: Found #{val} for #{attr}, but expected #{conf}" unless comp
              comp
            rescue
              self.log "Error: unable to determine config setting for #{attr}. Got #{line.inspect}"
              false
            end
          end
        end.all? {|x| x}
      end

    end
  end
end
