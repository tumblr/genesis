# Tasks and Targets

This directory contains sample tasks. written in ruby, and an example
Rakefile to control their execution.

Documentaion on coding tasks can be found in the DSL.md file.

## Targets Configuration

Tasks are grouped into top-level targets, which define the order of task execution, and provide a way to boot into Genesis and execute a set of tasks. Targets are defined (by default, feel free to write your own targets.yaml and/or ```Rakefile```) in a ```targets.yaml```, which looks something like the following:

```
intake:
  description: Perform intake on hardware
  tasks_array: &intake_tasks
  - SetupNTP
  - IpmiStart
  - AssetCreation
  - BiosConfigrC6105
  - BiosConfigrR720
  - FixDellFatPartitions
  tasks:
  - *intake_tasks
  - Reboot
burnin:
  description: Cook CPUs
  tasks: &burnin_tasks
  - TimedBurnin
reboot:
  description: Reboot the machine
  tasks:
  - Reboot
shutdown:
  description: Halt the machine
  tasks:
  - Shutdown
classic:
  description: Run intake, burnin, then shutdown
  tasks:
  - *intake_tasks
  - *burnin_tasks
  - Shutdown
util:
  description: Utility Shell
  tasks: []
```

Each top level key is a target name, containing an optional description with the key ```description```, and the required key ```tasks``` is a list list of classes to run. In the provided ```Rakefile```, we flatten the ```tasks``` so you can leverage tagged lists in YAML to leverage some "inheritance", as you can see in the ```classic``` target. Tasks are executed sequentially, and ordering ```[A,B,C]``` implies that task C cannot be run until A and then B are run.

## Running Targets

The ```targets.yaml``` is used by the provided Rakefile to create a list of tasks, and handle setting up their dependencies. Genesis will automatically launch the rake task specified by the ```GENESIS_MODE``` kernel parameter passed via ipxe.

For example, booting your kernel with ```GENESIS_MODE=intake``` will automatically execute the ```intake``` rake task when Genesis is booted.

To test your ordering, you could run something like

    user@host tasks $ DRYRUN=true GENESIS_CONFIG=../myconfig.yaml GENESIS_TASKS_DIR=. GENESIS_LOG_DIR=/tmp rake intake


## Customizing for your environment

We provide a reasonable ```Rakefile``` that can consume ```targets.yaml``` that you are free to extend for your own purposes. However, nothing is preventing you from writing your own ```Rakefile``` that totally ignores the YAML config, and instead does crazy things like parallel tasks, complex dependency ordering, etc. 

Tumblr uses Genesis by maintaining a separate repository of our tasks and targets.yaml that are specific to our hardware and business needs. Genesis config.yaml's ```tasks_url``` points to the deployed tar.gz of our tasks bundle (rakefile and targets.yaml inclusive).

We welcome any contributions for tasks that are generally useful to the community into the public repository.

## Facts, Modules, and Helpers

Each task has its ```LOAD_PATH``` expanded so it may include extras under the ```modules/``` path. We have provided some example facts (available in Tasks with the ```facter``` method) that you can extend.

Other shared ruby mixins/helpers/what-have-you code can be loaded when bundled with your tasks when placed under ```modules```.



