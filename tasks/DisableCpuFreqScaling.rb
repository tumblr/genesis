class DisableCpuFreqScaling
  include Genesis::Framework::Task

  init do
    log "Make sure acpi-cpufreq is enabled"
    run_cmd('modprobe acpi-cpufreq')
  end

  run do
    cpu_dirs = '/sys/devices/system/cpu/cpu[0-9]*'
    Dir.glob(cpu_dirs).each do |dirname|
      File.open("#{dirname}/cpufreq/scaling_governor", 'w') { |f| f.write('performance') }
    end

    # Verify CPUs set to max freq 
    Dir.glob(cpu_dirs).each do |dirname|
      max = File.read("#{dirname}/cpufreq/cpuinfo_max_freq").strip
      cur = File.read("#{dirname}/cpufreq/cpuinfo_cur_freq").strip
      raise "Max CPU frequency did not take" unless max == cur
    end
  end

end

