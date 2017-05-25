class DisableCpuFreqScaling
  include Genesis::Framework::Task

  init do
    log "Make sure acpi-cpufreq is enabled" 
    run_cmd('modprobe acpi-cpufreq')
  end

  run do
    num_procs = run_cmd('cat /proc/cpuinfo | grep processor | wc -l')
    (0..(num_procs.to_i - 1)).each do |n|
      run_cmd("echo 'performance' > /sys/devices/system/cpu/cpu#{n}/cpufreq/scaling_governor")
    end
  end

end
