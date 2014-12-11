# unicorn settings
preload_app      true
timeout          60
worker_processes 2

# unicorn paths
pid    '/var/run/genesis/unicorn.pid'
listen 8888, :backlog => 2048

# app paths
stderr_path       '/var/log/genesis/genesis.log'
stdout_path       '/var/log/genesis/debug.log'
working_directory '/web'

# reload logic
before_fork do |server, worker|
  demoted_server_pid = "#{server.config[:pid]}.oldbin"

  unless demoted_server_pid == server.pid
    begin
      signal = case
      when (worker.nr + 1) >= server.worker_processes
        :QUIT
      else
        :TTOU
      end

      Process.kill signal, File.read(demoted_server_pid).to_i
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

