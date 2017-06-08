# Tasks DSL

Genesis tasks are ruby code extended with a small DSL described below.

## Blocks

A task should contain one or more of the following blocks which are run in this order:

1. `precondition` [1] - test that must succeed before this task can be considered for runing
2. `init` [2] - sets up the tasks environment before execution
3. `condition` [1] - tests for for things being ready to run
4. `run` [3] - the retriable action
5. `success` [3] - this runs if the action succeeded
6. `rollback` [3] - this runs if the action failed

* [1] the task is skipped if any of these returns false.  They take a **description** as their first argument.
* [2] return result ignored
* [3] the task fails, i.e. returns false, if any of these fail

Also, if an `exception` happens while executing any block, the task will fail.

## Run block options

The `run` block will be retried if the `retries` options is set and 
must finish within `timeout` seconds.

The following are helper function and options available in run blocks to help
out with performing the task.

* `retries count`

Takes an argument which is either an Enumerator, with a list of timeouts for
each retry, or a count which is the same as [0 .. (count-1)].  The default value
of [0, 1, 2].

Example:
[AssetCreation.rb](https://github.com/tumblr/genesis/blob/master/tasks/AssetCreation.rb#L4)

* `timeout secs`

Sets the number of seconds to wait for a `run` block to complete, default 0.

* `run_cmd *cmd, stdin_data: '', return_both_streams: false, return_merged_streams:
false`

Will execute an external command (like open3) logging errors and returning the
output.

Example:
[TimedBurnin.rb](https://github.com/tumblr/genesis/blob/master/tasks/TimedBurnin.rb#L31)
Function arguments:

* `config`

Gives access to the Genesis configuration information.

Example:
[BiosConfigrC6105.rb](https://github.com/tumblr/genesis/blob/master/tasks/BiosConfigrC6105.rb#L15)

* `log message`

Logs a message.

Example:
[AssetCreation.rb](https://github.com/tumblr/genesis/blob/master/tasks/AssetCreation.rb#L20)

* `install provider, *what`

Uses either the **yum** provider or the **gem** provider to (possibly) install
software.

When using the **gem** provider genesis will also try to require the gems. If
the name of your gem does not match what needs to be required, you can specify
paths to require like this:
```
install :gem, 'gem1', 'gem2' => ['gem2/foo', 'gem2/bar']
```
This will install `gem1` and `gem2` and require `gem1`, `gem2/foo` and
`gem2/bar`.

Example:
[TimedBurnin.rb](https://github.com/tumblr/genesis/blob/master/tasks/TimedBurnin.rb#L13)

* `fetch what, filename, base_url: ENV['GENESIS_URL']`

Downloads a file from a remote server to the specified filename, retrying if
needed.

Example:
[BiosConfigrC6105.rb](https://github.com/tumblr/genesis/blob/master/tasks/BiosConfigrC6105.rb#L17)

* `tmp_path filename`

Returns a temporary file with the specified name.

`tmp_path filename` returns a temporary file named *filename*

`description "My task description here"` sets the description of the Task, to appear in things like ```rake -T```

## Targets and Tasks

Tasks are grouped into top-level "targets", similar to systemd targets. You can specify what tasks belong to what target (and the order they execute in) in ```targets.yaml```, bundled in your tasks directory.

Example:
[BiosConfigrC6105.rb](https://github.com/tumblr/genesis/blob/master/tasks/BiosConfigrC6105.rb#L22)
