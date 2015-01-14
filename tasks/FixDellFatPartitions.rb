class FixDellFatPartitions
  include Genesis::Framework::Task

  description "Wipe any existing FAT partitions on all disks for Dells"

  precondition "is Dell?" do
    facter['manufacturer'].match(/dell/i)
  end

  precondition "is c6220 or r720?" do
    facter['productname'].match(/6220/i) or facter['productname'].match(/720/i)
  end

  init do
    install :rpm, 'parted'
  end

  condition "has broken fat partitions?" do
    output = run_cmd "/sbin/blkid | grep 'vfat' | grep -i 'DellUtility' || true"
    output.lines.count > 0
  end

  run do
    log "Grabbing the list of all FAT partitions on the system"
    fat_partitions = run_cmd("/sbin/blkid | grep 'vfat' | awk -F ':' '{print $1}'").lines
    fat_partitions.each do |part|
      matches = part.match(/\/dev\/(sd[a-z])(\d)/)
      if matches
        log "Found partition: " + part
        device = matches[1]
        partition_id = matches[2]

        is_usb = run_cmd("readlink $(dirname $(dirname $(ls -d /sys/bus/scsi/devices/**/block/" + device + "))) | grep -i 'usb2' || true").lines.count > 0

        if(!is_usb)
          log "Partition is not on a USB drive, so nuking..."
          run_cmd("/sbin/parted -s /dev/" + device + " rm " + partition_id)
          log "Partition successfully nuked..."
        end
      end
    end
  end

end

