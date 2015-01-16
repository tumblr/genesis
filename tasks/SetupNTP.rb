class SetupNTP
  include Genesis::Framework::Task

  precondition "has ntp server?" do
    not config['ntp_server'].nil?
  end

  init do
    install :rpm, "ntpdate", "util-linux-ng"
    prod = facter['productname'].nil? ? 'UNKNOWN' : facter['productname']
    log "Executing ntp setup for model #{prod} and asset #{facter['asset_tag']}"
  end

  run do
    run_cmd "/usr/sbin/ntpdate -u -b #{config['ntp_server']}"
    log "System time synced with #{config['ntp_server']}"
    run_cmd "/sbin/hwclock -u --systohc"
    log "Wrote system time to hardware clock"
  end
end
