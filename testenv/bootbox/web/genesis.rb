#
# Simple file server for genesis testing support

require 'sinatra/base'

module Genesis
  class App < Sinatra::Base 
    configure do
      enable :logging, :dump_errors, :raise_errors
    end

    get '/ipxe-images/:file?' do
      file =  File.join('', 'genesis', 'bootcd', 'output', params['file'])
      send_file file
    end

    get '/testenv/:file?' do
      file =  File.join('', 'testenv', params['file'])
      if ['.yaml', '.yml'].include? File.extname(file)
        send_file file, :type => 'application/x-yaml'
      else
        send_file file, :type => 'text/plain'
      end 
    end

    get '/tasks' do
      content_type "application/x-gzip"
      `GZIP=-f tar -ch -zf - /genesis/tasks 2>/dev/null`
    end

    get '/health' do
      content_type 'text/plain'
      "OK"
    end
  end
end
