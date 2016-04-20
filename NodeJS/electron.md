##Install Electron 2016-04-19

##### Clone the Quick Start repository
```bashe
$ git clone https://github.com/electron/electron-quick-start
```
#### Go into the repository
```bash
$ cd electron-quick-start
```

#### Install the dependencies and run
```bash
$ npm install && npm start

# Install the `electron` command globally in your $PATH
npm install electron-prebuilt -g


# Install as a development dependency
# navigate to your project folder first
npm install electron-prebuilt --save-dev 

```

## install Debug Tools 
#### Read this link
```bash
https://github.com/node-inspector/node-inspector
```
#### Usage 
```bash
npm install -g node-inspector

# Enable debug mode for Electron
# You can either start Electron with a debug flag like:
  
  electron --debug=5858 your/app
 ```
# Load the debugger UI
  open this link in the Chrome browser
```bash
http://127.0.0.1:8080/debug?ws=127.0.0.1:8080&port=5858 
```
## Using Native Node Modules
Read this link 
```bash
http://electron.atom.io/docs/v0.37.6/tutorial/using-native-node-modules/
```
#### Usage 
```bash 
 cd /path-to-module/
 HOME=~/.electron-gyp node-gyp rebuild --target=0.37.6 --arch=x64 --dist-url=https://atom.io/download/atom-shell
```
#### Note Importane `[Az Ravesh khode Framework Electron Estefade nakon]`
```bash
 cd /path-to-module/
 node-gyp rebuild --target=0.37.6 --arch=x64 --dist-url=https://atom.io/download/atom-shell
```
## Note : best IDE For Debug 
* <b>VS Code</b> [best source <https://cmatskas.com/creating-electron-apps-with-visual-studio-code/> ]

