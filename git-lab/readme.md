## How To Install and Configure GitLab on Ubuntu 16.04


#### Source :
[link1](https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-gitlab-on-ubuntu-16-04)
[link backup process](https://blue.cse.buffalo.edu/gitlab/help/raketasks/backup_restore.md)
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
______
### Backup
```bash
crontab -e

# There, add the following line to schedule the backup for everyday at 2 AM:
0 2 * * * /opt/gitlab/bin/gitlab-rake gitlab:backup:create CRON=1
```

You may also want to set a limited lifetime for backups to prevent regular backups using all your disk space. To do this add the following lines to /etc/gitlab/gitlab.rb and reconfigure:
``` bash
# limit backup lifetime to 7 days - 604800 seconds
gitlab_rails['backup_keep_time'] = 604800
```
______

### Restore
We will assume that you have installed GitLab from an omnibus package and run sudo gitlab-ctl reconfigure at least once.

First make sure your backup tar file is in /var/opt/gitlab/backups (or wherever gitlab_rails['backup_path'] points to).

sudo cp 1393513186_gitlab_backup.tar /var/opt/gitlab/backups/
Next, restore the backup by running the restore command. You need to specify the timestamp of the backup you are restoring.
``` bash
# Stop processes that are connected to the database
sudo gitlab-ctl stop unicorn
sudo gitlab-ctl stop sidekiq

# This command will overwrite the contents of your GitLab database!
sudo gitlab-rake gitlab:backup:restore BACKUP=1393513186

# Start GitLab
sudo gitlab-ctl start

# Create satellites
sudo gitlab-rake gitlab:satellites:create

# Check GitLab
sudo gitlab-rake gitlab:check SANITIZE=true
```
If there is a GitLab version mismatch between your backup tar file and the installed version of GitLab, the restore command will abort with an error. Install a package for the required version and try again.

