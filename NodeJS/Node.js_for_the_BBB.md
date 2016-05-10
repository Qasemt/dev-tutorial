### Node.js for the BeagleBone Black


#### Step 1: Prerequisites
```bash 

apt-get install python
apt-get install build-essential

```

#### Step 2: Download Node Source
Download the latest source code from the node.js website. At the time of writing it is version 0.10.5 so
adjust this to the desired version.
We will unpack it in the current directory. Specify the -C <path> option to extract it elsewhere.

source node.js [http://nodejs.org/dist/]
```bash

wget http://nodejs.org/dist/v0.12.8/node-v0.12.8.tar.gz
wget https://nodejs.org/dist/v4.4.4/node-v4.4.4.tar.gz --no-check-certificate
# baray board hay ghadimi mesle BBB in version (0.10.0) rahat compile 
# mishavad bad az compile az tarighe npm version jadide nodejs ra nasb konid
wget http://nodejs.org/dist/v0.10.0/node-v0.10.0.tar.gz 

tar xzvf node-v0.12.8.tar.gz

```
#### Step 3: Configure
At the time of this writing, there is a problem with the Google V8 Snapshot feature causing node to segmentation fault.
Snapshotting helps node start faster and is not a big-deal feature; we will just compile without it.
```bash
cd node-v0.12.8
./configure --without-snapshot

OR 

python ./configure --without-snapshot
```

#### Result 
```bash
{ 'target_defaults': { 'cflags': [],
                       'default_configuration': 'Release',
                       'defines': [],
                       'include_dirs': [],
                       'libraries': []},
  'variables': { 'arm_fpu': 'vfpv3',
                 'arm_neon': 0,
                 'armv7': 1,
                 'clang': 0,
                 'gcc_version': 47,
                 'host_arch': 'arm',
                 'node_install_npm': 'true',
                 'node_prefix': '',
                 'node_shared_cares': 'false',
                 'node_shared_http_parser': 'false',
                 'node_shared_libuv': 'false',
                 'node_shared_openssl': 'false',
                 'node_shared_v8': 'false',
                 'node_shared_zlib': 'false',
                 'node_tag': '',
                 'node_unsafe_optimizations': 0,
                 'node_use_dtrace': 'false',
                 'node_use_etw': 'false',
                 'node_use_openssl': 'true',
                 'node_use_perfctr': 'false',
                 'node_use_systemtap': 'false',
                 'python': '/usr/bin/python',
                 'target_arch': 'arm',
                 'v8_enable_gdbjit': 0,
                 'v8_no_strict_aliasing': 1,
                 'v8_use_arm_eabi_hardfloat': 'true',
                 'v8_use_snapshot': 'false'}}
creating  ./config.gypi
creating  ./config.mk
```
#### Step 4: Compile
We are ready to compile. It is going to take about a two-hour to complete — go get a cup of coffee.
```bash
make
```

#### Step 5: Verify
Now that the build has finished, we can verify that all looks well before we install it.
```bash

./node -e 'console.log("het werkt!");'
 ./node -v
 
```
#### Step 6: Install
Now that all looks well, we are ready install it.

```bash
make install
```
#### Step 7 : Reset Board 

#### Upgrade Node (old version [0.10.0] to new version)
best source : 

link 1 [https://davidwalsh.name/upgrade-nodejs].
link 2 [http://askubuntu.com/questions/426750/how-can-i-update-my-nodejs-to-the-latest-version]
```bash
sudo npm cache clean -f
sudo npm install -g n
sudo n stable
sudo ln -sf /usr/local/n/versions/node/<VERSION>/bin/node /usr/bin/node 
```

