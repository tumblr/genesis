class Reboot
  include Genesis::Framework::Task
  run do
    log "Rebooting machine..."
    run_cmd '/sbin/reboot -nf'
    log "Sleeping waiting for reboot"
    sleep
  end
end
