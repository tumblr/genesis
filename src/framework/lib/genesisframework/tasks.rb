require 'timeout'
require 'promptcli'
require 'yaml'

module Genesis
  module Framework
    module Tasks
      def self.load_config file
        begin
          data = File.read(file)

          ## TODO: consider tokenizing the keys of the hash? needed???
          Genesis::Framework::Utils.config_cache = YAML::load(data)
        rescue => e
          raise "Unable to parse config %s: %s" % [file, e.message]
        end
      end

      def self.has_block? blocks, sym
        blocks.has_key?(sym) && blocks[sym].respond_to?(:call)
      end

      def self.call_block blocks, sym, msg = nil
        if self.has_block? blocks, sym
          puts msg if msg
          blocks[sym].call
        else
          true
        end
      end

      def self.load_tasks dir
        # expand the LOAD_PATH to include modules, so facts are available
        $:.unshift File.join(File.expand_path(dir),'modules')
        puts "\nParsing tasks from directory: %s" % [dir]

        Dir.glob(File.join(dir,'*.rb')) do |f|
          begin
            Genesis::Framework::Tasks.class_eval File.read(f)
          rescue => e
            raise "Error parsing task %s: %s" % [f, e.message]
          end
        end

        @tasks = Genesis::Framework::Tasks.constants.select do |c|
          Genesis::Framework::Tasks.const_get(c).include?( Genesis::Framework::Task )
        end

        @tasks.sort!
      end

      def self.execute task_name
        puts "\n#{task_name}\n================================================="

        prompt_timeout = ENV['GENESIS_PROMPT_TIMEOUT'].to_i \
          || Genesis::Framework::Utils.config_cache['task_prompt_timeout'] \
          || 10
        if prompt_timeout > 0
          # only prompt if there is a resonable timeout
          return true unless Genesis::PromptCLI.ask("Would you like to run this task?", prompt_timeout, true)
        end

        task = Genesis::Framework::Tasks.const_get(task_name)

        if task.blocks.nil?
          puts "task is empty with nothing to do, skipping..."
          return true
        end

        begin
          puts "task is now testing if it needs to be initialized..."
          if task.blocks.has_key?(:precondition)
            task.blocks[:precondition].each do |description, block|
              puts "Testing: %s" % description
              unless self.call_block(task.blocks[:precondition], description)
                puts "task is being skipped..."
                return true
              end
            end
          end
        rescue => e
          task.log("task had error on testing if it needs initialization: %s" % e.message, :error)
          return false
        end

        begin
          puts "task is now initializing..."
          self.call_block(task.blocks, :init);
          puts "task is now initialized..."
        rescue => e
          task.log("task threw error on initialization: %s" % e.message, :error)
          return false
        end

        begin
          puts "task is now testing if it can run..."
          if task.blocks.has_key?(:condition)
            task.blocks[:condition].each do |description, block|
              puts "Checking: %s" % description
              unless self.call_block(task.blocks[:condition], description)
                puts "Conditional failed. Task is being skipped."
                return true
              end
            end
          end
        rescue => e
          task.log("task had error on testing if it needs running: %s" % e.message, :error)
          return false
        end

        success = nil
        task.options[:retries].each_with_index do |sleep_interval, index|
          attempt = index + 1
          begin
            task.log("task is attempting run #%d..." % [attempt])
            Timeout::timeout(task.options[:timeout]) do
              success = self.call_block(task.blocks, :run)
            end
            # a run block should raise an error or be false for a failure
            success = true if success.nil?
          rescue => e
             task.log("run #%d caused error: %s" % [attempt, e.message], :error)
             success = nil      # cause a retry
          end
          break unless success.nil? # if we got an answer, we're done
          task.log("task is sleeping for %d seconds..." % [sleep_interval])
          Kernel.sleep(sleep_interval)
        end
        success = false if success.nil? # must have used all the retries, fail

        if success
          success = self.call_block(task.blocks, :success)
          task.log("task is successful!")
        else
          task.log 'task failed!!!', :error
          if self.has_block? task.blocks, :rollback
            success = self.call_block(task.blocks, :rollback, "rolling back!")
          end
        end

        puts "\n\n"
        return success
      end

    end
  end
end
