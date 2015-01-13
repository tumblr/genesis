Genesis tasks are ruby code extended with a small DLS described below.
A task should contain one or more of the following blocks which are run in this order:

1. `precondition`[1] - test that must succeed before this task can be considered for runing
2. `init`[2] - sets up the tasks environment before execution
3. `condition`[1] - tests for for things being ready to run
4. `run`[3] - the retriable action
5. `success`[3] - this runs if the action succeeded
6. `rollback`[3] - this runs if the action failed

[1] the task is skipped if any of these returns false.  They take a **description** as their first argument.
[2] return result ignored
[3] the task fails, i.e. returns false, if any of these fail
Also, if an `execption` happens while executing any block, the task will fail.

The `run` block will be retried if the `retries` options is set and 
must finish within `timeout` seconds.

`retries` takes an argument which is either an Enumerator, with a list
of timeouts for each retry, or a count which is the same as
[0 .. (count-1)].  The default value of [0, 1, 2].

`timeout` the number of seconds to wait for a `run` block to complete,
default 0.

`run_cmd *cmd, stdin_data: '', return_both_streams: false,
return_merged_streams: false` will execute and external command (like
open3) logging errors and returning the output.

`config` gives access to the Genesis configuration information

`log message` logs a message

`install provider, *what` uses **yum** or **gem** to (possibly) install software.

`fetch what, filename, base_url: ENV['GENESIS_URL']` downloads *what* into *filename* retrying if needed.

`tmp_path filename` returns a temporary file named *filename*

`description "My task description here"` sets the description of the Task, to appear in things like ```rake -T```

## Target Membership

Tasks are grouped into top-level "targets", similar to systemd targets. You can specify what targets your task should be a part of with the following ```wanted_by``` directive:

   wanted_by :target_name
   
You may specify multiple target names here (for example, if task ```UpgradeBios``` is in both the :intake and :provisioning_prep targets, you can say ```wanted_by :intake, :provisioning_prep```)

Targets are implicitly created by being ```wanted_by``` a Task. There is a default ```util``` target that will run no tasks that is provided by the default Rakefile.

## Dependency Ordering

Tasks may express their dependencies in terms of other tasks within the target[s] they participate in. For example, the ```SetupBios``` Task may declare

    after_tasks :AssetCreation, :StartIpmiService

This states that ```SetupBios``` will only be run upon successful (or skipped) completion of Both the AssetCreation and StartIpmiService tasks. A failure (skips are not treated as failure) of either will prevent SetupBios from running.

These dependencies are specified within the context of a target. As such, any dependencies of a task T in a target X must also specify ```wanted_by X```, or rake will fail to run successfully due to missing dependencies.



