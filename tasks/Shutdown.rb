class Shutdown
  include Genesis::Framework::Task
  run do
    log "Shutting down machine..."
    run_cmd '/sbin/shutdown', '-h', 'now'
    log "Sleeping waiting for shutdown"
    sleep
  end
end
