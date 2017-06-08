#
# Simple file server for genesis testing support

require 'sinatra/base'

module Genesis
  class App < Sinatra::Base
    configure do
      enable :logging, :dump_errors, :raise_errors
    end

    def test_and_send_file file, *send_file_args
      if file.size > 0
        send_file file, *send_file_args
      else
        [404, 'file not found or empty']
      end
    end

    get '/ipxe-images/:file?' do
      file =  File.join('', 'genesis', 'bootcd', 'output', params[:file])
      test_and_send_file file
    end

    get '/gem/:name?' do
      # get the latest version gem of that name
      base =  File.join('', 'genesis', 'src' ,'*', params[:name])
      file = Dir.glob(base + '*.gem').sort.last
      test_and_send_file file
    end

    get '/testenv/:file?' do
      file =  File.join('', 'testenv', params[:file])
      if ['.yaml', '.yml'].include? File.extname(file)
        test_and_send_file file, :type => 'application/x-yaml'
      else
        test_and_send_file file, :type => 'text/plain'
      end
    end

    get '/tasks' do
      content_type "application/x-gzip"
      `GZIP=-f tar -chz -C /genesis -f - tasks 2>/dev/null`
    end

    get '/health' do
      content_type 'text/plain'
      "OK"
    end
  end
end
