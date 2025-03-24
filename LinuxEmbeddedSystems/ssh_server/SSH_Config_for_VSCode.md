# Remote - SSH Config for VS Code

1. Install **Remote - SSH** extension in VS Code.
2. Open `C:\Users\qasem\.ssh\config` via `Remote-SSH: Open SSH Configuration File`.
3. Add:
```
Host my-server
HostName server_ip
User username
IdentityFile C:\Users\any_username\.ssh\id_ed25519
```

Copy
4. Save and connect using `Remote-SSH: Connect to Host` > `my-server`.
