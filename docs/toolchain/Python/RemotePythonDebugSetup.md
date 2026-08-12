# Remote Python Debug Setup

This document provides a step-by-step guide to debugging a Python script on a remote board using `debugpy` and VS Code.

## Prerequisites

1.  VS Code is installed.
2.  Python 3 is installed on the remote board.
3.  `debugpy` is installed on the remote board (`pip install debugpy`).
4.  The remote board is accessible via SSH.
5.  The `gpio_test.py` file is located at `C:\Users\test_user\Documents\python_src\hardware_utils\`.
6.  The `startapp.bat` and `stopapp.bat` files are located in the `workspaceFolder`.

## Steps

1.  **`startapp.bat` File:**

    ```batch
    @echo off
    echo Starting Python script on remote board...

    :: Transfer file
    scp "C:\Users\test_user\Documents\python_src\hardware_utils\gpio_test.py" root@192.168.40.151:/root/board

    :: Run script with debugpy and wait-for-client
    ssh root@192.168.40.151 "python3 -m debugpy --listen 0.0.0.0:5679 --wait-for-client /root/board/gpio_test.py"

    echo Script started and waiting for debugger on port 5679.
    ```

    This file transfers the `gpio_test.py` script to the remote board and then runs it with `debugpy`. `wait-for-client` causes the script to wait for the debugger to connect.

2.  **`stopapp.bat` File:**

    ```batch
    @echo off
    echo Stopping Python script on remote board...

    :: Kill debugpy process
    ssh root@192.168.40.151 "pkill -f 'python3 -m debugpy'"

    echo Script stopped.
    ```

    This file stops the `debugpy` process on the remote board.

3.  **`tasks.json` File:**

    ```json
    {
        "version": "2.0.0",
        "tasks": [
            {
                "label": "startapp",
                "type": "shell",
                "command": "${workspaceFolder}\\startapp.bat",
                "problemMatcher": [],
                "options": {
                    "shell": {
                        "executable": "cmd.exe",
                        "args": ["/C"]
                    }
                }
            },
            {
                "label": "stopapp",
                "type": "shell",
                "command": "${workspaceFolder}\\stopapp.bat",
                "problemMatcher": [],
                "options": {
                    "shell": {
                        "executable": "cmd.exe",
                        "args": ["/C"]
                    }
                }
            }
        ]
    }
    ```

    This file defines two tasks, `startapp` and `stopapp`, to run the batch files.

4.  **`launch.json` File:**

    ```json
    {
        "version": "0.2.0",
        "configurations": [
            {
                "name": "Python: Current File (Local)",
                "type": "debugpy",
                "request": "launch",
                "program": "${file}",
                "console": "integratedTerminal"
            },
            {
                "name": "Python Board: Remote Debug",
                "type": "debugpy",
                "request": "attach",
                "preLaunchTask": "startapp",
                "postDebugTask": "stopapp",
                "connect": {
                    "host": "192.168.40.151",
                    "port": 5679
                },
                "pathMappings": [
                    {
                        "localRoot": "${workspaceFolder}",
                        "remoteRoot": "/root/board"
                    }
                ]
            }
        ]
    }
    ```

    This file defines two debug configurations:

    * `Python: Current File (Local)`: For debugging the Python script locally.
    * `Python Board: Remote Debug`: For debugging the Python script on the remote board. `preLaunchTask` and `postDebugTask` are used to run the batch files before and after debugging. `pathMappings` is used to map local and remote paths.

5.  **Run Debugging:**

    * In VS Code, open the `gpio_test.py` file.
    * Go to the Run and Debug tab.
    * Select the `Python Board: Remote Debug` configuration.
    * Click the Start Debugging button.

    VS Code will first run the `startapp` task, then connect to `debugpy` on the remote board, and start debugging. After debugging is finished, the `stopapp` task will be run.

## Tips

* Make sure the remote board's IP address and port are correct in the `launch.json` file.
* Make sure the `gpio_test.py` file path is correct in the `startapp.bat` file.
* To debug, you can set breakpoints in the `gpio_test.py` file.
* If you encounter an error, check the VS Code terminal output and the remote board's logs.
* If you need to check the GPIO performance of the remote board, use appropriate libraries such as `RPi.GPIO` (for Raspberry Pi).

With this document, you can easily debug your Python scripts on the remote board.
