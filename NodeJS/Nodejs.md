### Requirment for install in arm board (hatman anjam bede )
```bash
sudo apt-get install build-essential
apt-get update 
apt-get upgrade 
```
#### install python 2.7.6 if you need 

[See this Document ](https://github.com/Qasemt/dev-tutorial/blob/master/Python/Installing_Python_on_Beaglebone_Black.md)


#### update  node-gyp (khily mohem ****)
agar heyne build kardan package ha mesel [serialport] khataye 
( gyp_main.py: error: no such option: --no-parallel)  dad hatman akharin versionesho begir
```bash
npm install node-gyp@latest

```

---


#### NPM Install on Linux 
##### method 1 (best Method)
[(See Doc) ](https://github.com/Qasemt/dev-tutorial/blob/master/NodeJS/Node.js_for_the_BBB.md)

##### method 2

```bash
sudo apt-get remove --purge node 
sudo apt-get install nodejs
sudo apt-get install npm
```


#### any Command 
```bash
You can upgrade npm and nodejs using npm itself as well
sudo npm install -g npm

sudo npm cache clean -f
sudo npm install n -g

sudo  npm cache clean -f
sudo npm install -g n
sudo  n stable
OR 
sudo n 0.12.7 
copy to usr/local/n/versions/node/0.12.7/

npm cache ls

npm cache clean 

global path = /usr/local/lib/node_modules

npm install <module> --save-dev



```
###remove  Package 
```bash
 npm uninstall <module> 
```

### install Local Package 
```bashe 
npm install 
```

####Dependency pack for build (hatman update shavand )
```bash
npm install -g node-gyp
npm install -g node-pre-gyp
```

#### Node JS Debugger
```bash
npm install -g node-inspector
npm install -g node-inspector@0.10.0

npm uninstall -g node-inspector
```
#### Kill Nodejs

```bash
ps aux | grep node
killall -9 any node
```
#### Type script install 
[source 1 ](https://code.visualstudio.com/docs/languages/typescript)
``` console 
npm install -g typescript
```


## How to: Allow Node to bind to port 80 and 443 without sudo

### TL;DR

*Only do this if you understand the consequences: all node programs will be able to bind on ports < 1024*

    sudo setcap 'cap_net_bind_service=+ep' /usr/bin/node
     or 
     sudo setcap 'cap_net_bind_service=+ep' $(readlink -f $(which node))
Important: your node location may vary. Use `which node` to find it, or use it directly in the command:

    sudo setcap 'cap_net_bind_service=+ep' `which node`

### Explanation
