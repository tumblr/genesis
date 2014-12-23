require "httparty"

module Genesis
  module RetryingFetcher
    FETCH_RETRY_INTERVALS = [0,1,5,30,60,90,180,300,300,300,300,300,1800,3600]
    
    def self.get what, base_url = '', fetch_intervals = FETCH_RETRY_INTERVALS
      what = File.join(base_url, what) unless base_url.empty?
      fetch_intervals.each_with_index do |sleep_interval, index|
        Kernel.sleep(sleep_interval) 
        puts "Fetching '%s' (Attempt #%d)..." % [what, index+1]
  
        begin 
          response = HTTParty.get(what)
          next unless response.response_code == 200
          if block_given?
            yield response.body_str
            break
          else  
            return response.body_str
          end
        rescue  => e
          puts "RetyingFetcher.get error: %s" % e.message
        end
      end
      nil
    end
  end
end
