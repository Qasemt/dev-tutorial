# SSH Key Setup for Passwordless Board Connection

This guide explains how to connect to your board using SSH keys, eliminating the need for password entry.

## Benefits

* **Enhanced Security:** SSH keys offer greater security compared to password authentication.
* **Convenience:** No more typing passwords for each connection.

## Steps

1.  **Generate SSH Key Pair on Windows**

    * Open Git Bash or PowerShell and execute the following command:

    ```bash
    ssh-keygen -t ed25519
    ```

    * When prompted for the file location, press Enter to use the default path.
    * You can leave the passphrase empty (press Enter) for passwordless access.

    This will create two files:

    * `id_ed25519`: The private key.
    * `id_ed25519.pub`: The public key.

2.  **Transfer the Public Key to the Board**

    * **Method 1 (using `scp`)**:

        * In Git Bash or PowerShell, run the following command:

        ```bash
        scp C:\Users\YourUsername\.ssh\id_ed25519.pub root@192.168.40.151:/root/.ssh/authorized_keys
        ```

        * Enter the password `1234` when prompted.
        * If the `/root/.ssh` directory doesn't exist, create it first with:

        ```bash
        ssh root@192.168.40.151 "mkdir -p /root/.ssh"
        ```

    * **Method 2 (manual)**:

        * Connect to the board using:

        ```bash
        ssh root@192.168.40.151
        ```

        * Enter the password `1234`.
        * Open the `/root/.ssh/authorized_keys` file with a text editor.
        * Copy the contents of `id_ed25519.pub` into the file.
