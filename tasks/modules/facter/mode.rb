Facter.add(:mode) do
  setcode do
    cmdline = File.new("/proc/cmdline", "r").gets
    md = /GENESIS_MODE=(\S*)/.match(cmdline)
    md.captures[0]
  end
end
