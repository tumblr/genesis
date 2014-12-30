# dell system serial 
Facter.add(:service_tag) do
  setcode do
    vendor = Facter.value(:manufacturer)
    case vendor
    when /dell/i
      system_serial = Facter::Util::Resolution.exec('/usr/sbin/dmidecode -s system-serial-number')
      system_serial.strip
    end
  end
end
