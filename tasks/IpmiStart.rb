class IpmiStart
  include Genesis::Framework::Task

  description "Start up the IPMI services"

  init do
    install :rpm, 'dmidecode', 'OpenIPMI', 'OpenIPMI-tools', 'syscfg'
  end

  condition "ipmi service present?" do
    %w[/etc/init.d/ipmi].all? do |f|
      x = File.executable? f
      log "#{f} missing!" unless x
      x
    end
  end

  run do
    run_cmd('service ipmi start')
  end

end
