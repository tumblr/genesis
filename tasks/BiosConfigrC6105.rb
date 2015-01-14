class BiosConfigrC6105
  include Genesis::Framework::Task

  description "Configure BIOS for C6105"

  precondition "has productname?" do
    not facter['productname'].nil?
  end

  precondition "is c6105?" do
    facter['productname'].match(/6105/i)
  end

  init do
    log "Fetching and installing 'setupbios' RPM"
    install :rpm, "setupbios"
    if config['bios_settings']['c6105']
      log "bios-configr fetching bios settings file '%s'" % config['bios_settings']['c6105'] 
      fetch config['bios_settings']['c6105'], 'bios-settings', base_url: config['bios_settings']['base_url']
    end
  end

  condition "bios-settings file exists?" do
    File.exists? tmp_path('bios-settings')
  end

  run do 
    log "Running setupbios to apply bios settings to this machine"
    run_cmd "cd /usr/local/dell; /usr/local/dell/setupbios setting readfile %s" % tmp_path('bios-settings')
  end
end

