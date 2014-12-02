require "curb"

module Genesis
  module RetryingFetcher
    FETCH_RETRY_INTERVALS = [0,1,5,30,60,90,180,300,300,300,300,300,1800,3600]
  
    def self.get what, base_url, fetch_intervals = FETCH_RETRY_INTERVALS
      fetch_intervals.each_with_index do |sleep_interval, index|
        Kernel.sleep(sleep_interval) 
        puts "Fetching '%s' (Attempt #%d)..." % [what, index+1]
  
        begin 
          puts File.join(base_url, what)
          response = Curl.get(File.join(base_url, what))
          next unless response.response_code == 200
          if block_given?
            yield response.body_str
            break
          else  
            return response.body_str
          end
        rescue Curl::Err::CurlError => e
          puts "Curl fetch error: %s" % e.message
        end
      end
      
      nil
    end
  end
end
