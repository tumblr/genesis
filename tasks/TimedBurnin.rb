class TimedBurnin 
  include Genesis::Framework::Task

  description "Performs burnin for a specified duration"

  precondition "has asset tag?" do
    not facter['asset_tag'].nil?
  end

  precondition "is running in burnin mode?" do
    ENV['GENESIS_MODE'] == "burnin" or ENV['GENESIS_MODE'] == "classic"
  end

  init do
    install :rpm, "breakin", "hpl", "screen" 
  end

  run do 
    burnin_duration = 48
    burnin_cmd = "/usr/bin/screen -dmS genesis_burnin /etc/breakin/startup.sh"

    log "Executing new system burnin for #{burnin_duration} hours..."
    
    start = Time.now

    begin
      log "Burnin starting via command: #{burnin_cmd}"

      # this is a print rather than a log as Collins has timestamps already
      print "Burnin started at: #{Time.now}"

      # turning on the IPMI light to blinking
      run_cmd("/usr/bin/ipmitool chassis identify 255")

      # begin burnin process
      run_cmd(burnin_cmd) 

      # for a simple logging buffer, we log every
      # logging_interval loops of the below do/while loop
      # (aka every 2hrs with current 3m sleep duration)
      logging_interval = 40 
      # starting at 39 so it will write a log after first sleep duration
      logging_counter = 39 

      # this has to stay below ~200 seconds to be safe as the max time we
      # can pass to the ipmitool is 255 for it to keep the light blinking
      sleep_duration = 3*60 

      loop_continue = true

      begin 
        sleep sleep_duration

        logging_counter += 1
        runtime_seconds = Time.now - start
        runtime_hours = runtime_seconds.to_i / 3600
         
        self.parse_breakin_state 
        successful_tests = self.get_breakin_success_count
        failed_tests = self.get_breakin_failure_count

        if failed_tests > 0

          run_cmd("/usr/bin/ipmitool chassis identify force")

          self.log_failed_tests

          loop_continue = false

        else

          # refresh the IPMI blinker fluid
          run_cmd("/usr/bin/ipmitool chassis identify 255")

          if logging_counter > logging_interval
            begin
              log "Burnin has been executing for #{runtime_hours} hours with #{successful_tests} tests ran successfully..."
            rescue Exception
              # if collins is down, don't blow up the Burnin process
              # we only rescue this one and not the other logging lines
              # as this one is the only one which repeats multiple times
              # during execution and we don't "want" it to break on failure
            end 

            logging_counter = 0
          end

          if runtime_hours >= burnin_duration
            # turn off the IPMI light
            run_cmd("/usr/bin/ipmitool chassis identify 0")
  
            # tell Collins we are done so we don't run Burnin automatically again on reboot
            collins.set_attribute!(facter['asset_tag'], :BURNIN_COMPLETE, true) 
          
            log "Burnin complete! Machine will power off in 30 seconds (unless you hit cntrl-c now)..."
            sleep 30
            run_cmd("shutdown -h now") 
          end 

        end

      end while loop_continue

    rescue Exception => e
      # turn the IPMI light on solid
      run_cmd("/usr/bin/ipmitool chassis identify force")
      log "The burnin process threw an exception... #{e.message}"
    end
  end

  def self.parse_breakin_state
    begin
      breakin_data_file = '/var/run/breakin.dat'
      @@breakin_state = Hash[File.read(breakin_data_file).scan(/(.+?)="(.*)"\n/)] 
    rescue Exception => e
      log "Caught exception #{e.message} while trying to parse breakin state file!"
      @@breakin_state ||= {}
    end
  end

  def self.get_breakin_success_count
    total_success = 0
    burnin_qty = @@breakin_state["BURNIN_QTY"].to_i - 1

    for test_id in 0..burnin_qty 
      total_success += @@breakin_state["BURNIN_#{test_id}_PASS_QTY"].to_i 
    end

    total_success
  end

  def self.get_breakin_failure_count
    @@breakin_state["BURNIN_TOTAL_FAIL_QTY"].to_i 
  end

  def self.log_failed_tests
    burnin_qty = @@breakin_state["BURNIN_QTY"].to_i - 1

    for test_id in 0..burnin_qty 
      test_failures = @@breakin_state["BURNIN_#{test_id}_FAIL_QTY"].to_i
      if test_failures > 0
        test_name = @@breakin_state["BURNIN_#{test_id}_NAME"]
        test_successes = @@breakin_state["BURNIN_#{test_id}_PASS_QTY"].to_i
        log "Burnin test #{test_name} failed #{test_failures} times and succeeded #{test_successes} times..."
      end
    end

  end
end
