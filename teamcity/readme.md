#### Source :
* [link1](https://makandracards.com/konjoot/21071-ubuntu-12-04-teamcity-build-agent-installation)
* [link2 java setup](https://www.atlantic.net/cloud-hosting/how-to-install-java-jre-jdk-ubuntu-16-04/)

## Ubuntu 12.04 TeamCity build agent installation
#### install tools
> svn for check build number (if you need)
``` console
apt-get install subversion
```
_________________
#### Install Java Oracle JRE or JDK on Ubuntu 16.04
``` consle
sudo apt install python-software-properties
sudo add-apt-repository ppa:webupd8team/java
sudo apt update
sudo apt install oracle-java8-installer
sudo update-alternatives --config java
```
_________________
#### Build tool for nginx 
* [link build tools](https://github.com/Qasemt/dev-tutorial/blob/master/LinuxEmbeddedSystems/3.nginx.md)
_________________
``` console 
mkdir -p workspace/buildAgent & cd workspace/buildAgent

wget http://your_teamcity.server.com:8111/update/buildAgent.zip
unzip buildAgent.zip
chown -R your_user:your_group ../buildAgent
cp conf/buildAgent.dist.properties conf/buildAgent.properties
nano conf/buildAgent.properties
```
##### There are fields which you must update:
``` bash 
# your TeamCity server address:
serverUrl=http://your_teamcity.server.com:8111/
 

# buildAgent's name, which would displayed on Agents page in your TeamCity server UI:
name=ubuntu_build_agent

 
# this field  leave blank, agent fill it after first connect to server:
authorizationToken=

```
### Make bin files executable:
``` console 
chmod u+x bin/*.sh
``` 
### Build agent usage:
_________________
``` bash 
$ ./bin/agent.sh

  JetBrains TeamCity Build Agent
  Usage:
  ./bin/agent.sh start     - to start build agent in background
  ./bin/agent.sh stop      - to stop build agent after current build finish
  ./bin/agent.sh run         - to start build agent in the current console
  ./bin/agent.sh stop force  - to stop build agent terminating currently running build

```
_________________
## Run Teamcity Agent  as boot 
step 1 : 

``` console
sudo nano /etc/init.d/teamcity-agent
```
_________________
``` bash
#! /bin/sh
### BEGIN INIT INFO
# Provides:          teamcity-agent
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Execute TeamCity Agent 
# Description:
### END INIT INFO

# Common parameters, do not edit:
PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC="TeamCity Agent"
NAME=teamcity-agent
SCRIPTNAME=/etc/init.d/$NAME
#
# User specific parameters:
USERNAME=admin
GROUP=admin
AGENT_HOME=~/workspace/buildAgent
#

case "$1" in
  start)
    logger -t teamcity-agent "starting $DESC "
    sudo -H -u $USERNAME /bin/bash --login -c "$AGENT_HOME/bin/agent.sh start"
    ;;
  stop)
    logger -t teamcity-agent "stopping  $DESC "
    sudo -H -u $USERNAME /bin/bash --login -c "$AGENT_HOME/bin/agent.sh stop"
    ;;
  *)
    echo "Usage: $SCRIPTNAME {start|stop}" >&2
    exit 3
    ;;
esac

```
________
step 2:
``` console 
sudo chmod +x /etc/init.d/teamcity-agent
sudo update-rc.d teamcity-agent defaults
```
for test 
``` console 
sudo /etc/init.d/teamcity-agent start
```
