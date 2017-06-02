# For background on this read the following two links
# https://wiki.gentoo.org/wiki/Power_management/Processor
# https://wiki.archlinux.org/index.php/CPU_frequency_scaling

class DisableCpuFreqScaling
  include Genesis::Framework::Task

  init do
    run_cmd('modprobe acpi-cpufreq')
  end

  run do
    cpu_dirs = '/sys/devices/system/cpu/cpu[0-9]*/cpufreq'
    Dir.glob(cpu_dirs).each do |dirname|
      File.write("#{dirname}/scaling_governor", 'performance')
    end

    # Verify CPUs set to max freq 
    Dir.glob("#{cpu_dirs}").each do |dirname|
      max = File.read("#{dirname}/cpuinfo_max_freq").strip
      cur = File.read("#{dirname}/cpuinfo_cur_freq").strip
      raise "Max CPU frequency did not take" unless max == cur
    end
  end
end

