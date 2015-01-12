# Tasks DSL

Genesis tasks are ruby code extended with a small DSL described below.

## Blocks

A task should contain one or more of the following blocks which are run in this order:

1. `precondition`[1] - test that must succeed before this task can be considered for runing
2. `init`[2] - sets up the tasks environment before execution
3. `condition`[1] - tests for for things being ready to run
4. `run`[3] - the retriable action
5. `success`[3] - this runs if the action succeeded
6. `rollback`[3] - this runs if the action failed

* [1] the task is skipped if any of these returns false.  They take a **description** as their first argument.
* [2] return result ignored
* [3] the task fails, i.e. returns false, if any of these fail

Also, if an `exception` happens while executing any block, the task will fail.

## Run block options

The `run` block will be retried if the `retries` options is set and 
must finish within `timeout` seconds.

The following are helper function and options available in run blocks to help
out with performing the task.

* `retries` - takes an argument which is either an Enumerator, with a list
of timeouts for each retry, or a count which is the same as
[0 .. (count-1)].  The default value of [0, 1, 2].

* `timeout`

Sets the number of seconds to wait for a `run` block to complete, default 0.

* `run_cmd`

Will execute an external command (like open3) logging errors and
returning the output.

Function prototype:
```
run_cmd *cmd, stdin_data: '', return_both_streams: false, return_merged_streams:
false
```

* `config`

Gives access to the Genesis configuration information.

* `log`

Logs a message.

Function prototype:
```
log message
```

* `install`

Uses **yum** or **gem** to (possibly) install software.

Function prototype:
```
def install provider, *what
```

* `fetch`

Downloads a file from a remote server to the specified filename, retrying if
needed.

Function prototype:
```
fetch what, filename, base_url: ENV['GENESIS_URL']
```

* `tmp_path`

Returns a temporary file with the specified name.

Function prototype:
```
tmp_path filename
```
