require 'yaml'

module Genesis
  class Config
    def self.hash_from_yaml_file filename
      begin
        config = YAML::load(File.open(filename))
        hash = self.symbolize_hash(config)
        self.resolve_yaml_configs hash
      rescue Exception => e
        raise StandardError.new("Unable to parse yaml in #{filename}: #{e}")
      end
    end

    def self.symbolize_hash hash
      (raise StandardError.new("symbolize_hash called without a hash")) unless hash.is_a?(Hash)
      tmp = {}
      hash.inject({}) do |result, (k,v)|
        if v.is_a?(Hash) then
          result[k.to_sym] = self.symbolize_hash(v)
        else
          result[k.to_sym] = v
        end
        result
      end
    end

    # Find keys in hash matching {foo}_cfg_yaml, parse the referenced yaml
    # file, and turn the parsed yaml into the value associated with the key
    # {foo} in the original hash
    def self.resolve_yaml_configs hash
      hash.inject({}) do |result, (k,v)|
        if k.to_s =~ /^(.*)_cfg_yaml$/ then
          thash = self.hash_from_yaml_file v
          if thash[$1.to_sym] then
            result[$1.to_sym] = thash[$1.to_sym]
          else
            result[$1.to_sym] = thash
          end
        else
          result[k] = v
        end
        result
      end
    end

  end
end

