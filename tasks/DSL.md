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
