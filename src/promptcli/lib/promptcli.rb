require "termios"

module Genesis
  module PromptCLI
    def self.ask question, seconds = 30, default = false
      old_attributes = Termios.tcgetattr($stdin)
      new_attributes = old_attributes.dup
      new_attributes.lflag &= ~Termios::ICANON
      Termios::tcsetattr($stdin, Termios::TCSANOW, new_attributes)
  
      start_time   = Time.now
      end_time     = start_time + seconds
      begin
        prompt_format = "%s [%d] (%s/%s) "
        prompt = prompt_format % [question, seconds.to_i, default ? "Y" : "y", default ? "n" : "N"] 
        prompt_length = seconds < 10 ? prompt.length+1 : prompt.length
        $stdout.write(prompt)
        $stdout.flush
 
        # Wait until input is available
        if select([$stdin], [], [], seconds % 1)
          case char = $stdin.getc
          when ?y, ?Y then return true
          when ?n, ?N then return false
          else                  # NOOP
          end
        end
 
        $stdout.write("\b" * prompt_length)
        $stdout.flush
    
        seconds = end_time - Time.now
      end while seconds > 0.0
  
      return default
    ensure
      Termios::tcsetattr($stdin, Termios::TCSANOW, old_attributes)
      $stdout.puts
    end
  end
end
