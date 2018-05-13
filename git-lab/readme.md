## How To Install and Configure GitLab on Ubuntu 16.04


#### Source :
[link1](https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-gitlab-on-ubuntu-16-04)
#### S1 :
```bash
sudo apt-get update
sudo apt-get install ca-certificates curl openssh-server postfix
```
#### S2 :
```bash
cd /tmp
curl -LO https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh

less /tmp/script.deb.sh

sudo bash /tmp/script.deb.sh

sudo apt-get install gitlab-ce
```
______
### Editing the GitLab Configuration File
```bash
sudo nano /etc/gitlab/gitlab.rb
```

#### Reset after config.
```bash
sudo gitlab-ctl reconfigure
sudo gitlab-ctl restart
```
_______
##### LDAP Test in ubuntu
```bash
sudo apt install ldap-utils
```
```
> ldapsearch -x -LLL -h [host] -D [user] -w [password] -b [base DN] -s sub "([filter])" [attribute list]
> ldapsearch -x -LLL -h 172.XX.X.X -D XX@domain -w xxxx  -b ou=karaj-users,dc=n2it,dc=local
```
_______
##### LDAP CONFIG 
```yaml
gitlab_rails['ldap_enabled'] = true
gitlab_rails['ldap_servers'] = YAML.load <<-EOS # remember to close this block with 'EOS' below
 main:
  label: 'ActiveDirectory'
  host: '172.20.4.2'
  port: 389 #Change to 636 if using LDAPS
  method: 'plain' # Change to "tls" if using LDAPS
  uid: 'sAMAccountName' # Don't change this
  bind_dn: 'at@n2it'
  password: 'at1234'
  timeout: 20000
  active_directory: true
  allow_username_or_email_login: true
  block_auto_created_users: false
  base: 'ou=karaj-users,dc=n2it,dc=local'
  user_filter: ''
  # attributes:
       # username: ['uid', 'userid', 'sAMAccountName']
       # email:    ['mail', 'email', 'userPrincipalName']
       # name:       'cn'
       # first_name: 'givenName'
       # last_name:  'sn'
  # group_base:  'ou=karaj-users,dc=n2it,dc=local'
  # Optional: the next line specifies that only members of the user group "gitlab-users" can authenticate to Gitlab:
  #user_filter: '(memberOf:1.2.840.113556.1.4.1941:=CN=GITLAB-USERS,CN=Users,DC=CORP,DC=COM)'
EOS
```
