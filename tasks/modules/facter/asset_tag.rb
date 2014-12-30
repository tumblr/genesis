Facter.add(:raw_asset_tag) do
  setcode do
    product = Facter.value(:productname)
    case product
    when /R720/i
      # FRU in R720 is shady, we cant use dmidecode or ipmitool fru print reliably
      output = Facter::Util::Resolution.exec('/opt/dell/toolkit/bin/syscfg --asset')
      output.split('=')[1].strip
    else
      # we will just fall back to dmidecode
      Facter::Util::Resolution.exec('/usr/sbin/dmidecode -s chassis-asset-tag')
    end
  end
end

Facter.add(:asset_tag) do
  # this will be nil if the claimed asset tag doesnt match our required naming scheme
  setcode do
    tag = Facter.value(:raw_asset_tag)
    unless tag.nil?
      tag.strip!
      case tag
      when /^(\d{6})$/
        $1
      end
    end
  end
end
