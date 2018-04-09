### Editing the GitLab Configuration File
```bash
sudo nano /etc/gitlab/gitlab.rb
```

#### Reset after config.
```bash
sudo gitlab-ctl reconfigure
sudo gitlab-ctl restart
```

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
