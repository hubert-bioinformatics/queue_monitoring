## queue_monitoring
This repository contains the script used to check queue status.
The contents of this repository are 100% open source.


## Table of Contents
* [Intallation](#installation)
* [Usage](#usage)
* [Contributing](#contributing)
* [Credits](#credits)
* [License](#license)


## <a name="installation">Installation</a>
### Requirements
* The server state that SGE(Sun Grid Engine) has already been installed is needed to run the script


## <a name="usage">Usage</a>

* Basic
  * The script check out usage of queue (containing nodes), and visualize it.
  * The output is a screen that is periodically refreshed. (interval is 0.01s)
  * Default format is a table that contains 4 columns
    * Queue Name: [Queue name], [Node name]
    * Type: 'slot', 'mem' (memory), 'load' (load average)
    * QUEUE USAGE: [ colored box that represents usage ratio of slot / mem / load ave. ]
    <br>
    
     ||green|yellow|red|
     |---|---|---|---|
     |slot| ratio ＜ 30 | 30 ≤ ratio ＜ 70 | 70 ≤ ratio |
     |mem| ratio ＜ 30 | 30 ≤ ratio ＜ 70 | 70 ≤ ratio |
     |load| ratio ＜ 20 | 20 ≤ ratio ＜ 50 | 50 ≤ ratio |
     <br>
    
    * Value: [ using ] / [ total ] ( [ratio] )
    <br>

     [![basic](https://github.com/hubert-bioinformatics/queue_monitoring/blob/master/README_images/basic.png)](https://github.com/hubert-bioinformatics/queue_monitoring/blob/master/README_images/basic.png)
     <br>
* screen mode
  * There're two types of screen mode by full width.
  * Dual mode (recommended)
    * when the full width is over 202
    * Outputs of two nodes are in the same line,
    * and that means as many as nodes can be displayed at once.
    <br>

     [![dualmode](https://github.com/hubert-bioinformatics/queue_monitoring/blob/master/README_images/dual_mode.png)](https://github.com/hubert-bioinformatics/queue_monitoring/blob/master/README_images/dual_mode.png)
     <br>
  * Single mode
    * when the full width is in 93 ~ 201
    * An output of a node is in a line.
    * May need to scroll to see all nodes.
    <br>

     [![singlemode](https://github.com/hubert-bioinformatics/queue_monitoring/blob/master/README_images/single_mode.png)](https://github.com/hubert-bioinformatics/queue_monitoring/blob/master/README_images/single_mode.png)
     <br>

* demo play
<br>

[![usage](https://github.com/hubert-bioinformatics/queue_monitoring/blob/master/queue_monitoring_usage.gif)](https://github.com/hubert-bioinformatics/queue_monitoring/blob/master/queue_monitoring_usage.gif)


## <a name="contributing">Contributing</a>


Welcome all contributions that can be a issue report or a pull request to the repository.


## <a name="credits">Credits</a>


hubert (Jong-Hyuk Kim)


## <a name="license">License</a>

Licensed under the MIT License.

