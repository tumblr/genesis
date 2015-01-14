class BiosConfigrR720
  include Genesis::Framework::Task

  description "Configure BIOS for R720s"

  precondition "has productname?" do
    not facter['productname'].nil?
  end

  precondition "is R720?" do
    facter['productname'].match(/720/i)
  end

  init do
    log "Fetching and installing 'setupbios' RPM"
    install :rpm, "setupbios"
  end

  run do 
    log "Applying bios settings to this R720..."
    {
      'AcPwrRcvry'            => 'On',
      'AcPwrRcvryDelay'       => 'random',
      'SerialComm'            => 'onconredircom2',
      'SerialPortAddress'     => 'serial1com1serial2com2',
      'ExtSerialConnector'    => 'serial1',
      'FailSafeBaud'          => '115200',
      'ConTermType'           => 'vt100vt220',
      'RedirAfterBoot'        => 'disable',
      'extserial'             => 'com1',
      'BootMode'              => 'bios',
      'IntNic1Port1BootProto' => 'pxe',
      'IntNic1Port2BootProto' => 'pxe',
      'IntNic1Port3BootProto' => 'pxe',
      'IntNic1Port4BootProto' => 'pxe',
      'BootSeq'               => 'NIC.Integrated.1-1-1,NIC.Integrated.1-2-1,NIC.Integrated.1-3-1,NIC.Integrated.1-4-1,HardDisk.List.1-1',
      'SysProfile'            => 'perfoptimized'
    }.map do |key,value|
      self.apply_bios_setting key, value
    end 
  end

  def self.apply_bios_setting key, value
    log "Setting bios setting \"#{key}\" to value \"#{value}\"..."
    run_cmd("/opt/dell/toolkit/bin/syscfg --#{key}=#{value}") 
  end
end

