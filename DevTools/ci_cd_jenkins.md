* https://www.zenesys.com/blog/install-and-configure-jenkins-on-centos-7 not used
* https://www.digitalocean.com/community/tutorials/how-to-install-jenkins-on-ubuntu-22-04

## Prerequisites
### Minimum hardware requirements:
```
256 MB of RAM

1 GB of drive space (although 10 GB is a recommended minimum if running Jenkins as a Docker container)

Recommended hardware configuration for a small team:

4 GB+ of RAM

50 GB+ of drive space
```

---

## Installing Jenkins in alpine 

### install jdk 8 for alpine 

```
$ apk add openjdk8-jre
```

### install GPG 
```
apk add --no-cache gnupg
```

```
$ mkdir /etc/apt/sources.list.d
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key |sudo gpg --dearmor -o /usr/share/keyrings/jenkins.gpg
```

```
 mkdir -p /etc/apt/sources.list.d/
sudo sh -c 'echo deb [signed-by=/usr/share/keyrings/jenkins.gpg] http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
```
install jenkins
