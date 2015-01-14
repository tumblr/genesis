class AssetCreation
  include Genesis::Framework::Task

  description "Create asset if not yet in Collins"
  retries [0,1,5,10,21,33,33,33,39,42,60,60,60,90,120,300].to_enum

  precondition "has asset tag?" do
    not facter['asset_tag'].nil?
  end

  precondition "asset tag doesn't exist in collins?" do
    not collins.exists?(facter['asset_tag'])
  end

  run do
    begin
      # the default is to generate_ipmi, but be explicit since we know we need it
      collins.create!(facter['asset_tag'], :generate_ipmi => true)
    rescue Collins::RequestError => e
      if e.code == 409
        log "Asset %s already exists in collins" % facter['asset_tag']
      else
        log "Error trying to create asset in collins. Message: %s" % e.message
        raise e
      end
    end
  end
end
