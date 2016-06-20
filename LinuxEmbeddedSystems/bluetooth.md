```bash
pair 40:40:A7:7F:46:4D 
bluetoothctl 40:40:A7:7F:46:4D
connect 40:40:A7:7F:46:4D 
remove 40:40:A7:7F:46:4D
trust 40:40:A7:7F:46:4D 
```
#### bluetoothctl -a
```bash
  list                       List available controllers
  show [ctrl]                Controller information
  select <ctrl>              Select default controller
  devices                    List available devices
  paired-devices             List paired devices
  power <on/off>             Set controller power
  pairable <on/off>          Set controller pairable mode
  discoverable <on/off>      Set controller discoverable mode
  agent <on/off/capability>  Enable/disable agent with given capability
  default-agent              Set agent as the default one
  scan <on/off>              Scan for devices
  info <dev>                 Device information
  pair <dev>                 Pair with device
  trust <dev>                Trust device
  untrust <dev>              Untrust device
  block <dev>                Block device
  unblock <dev>              Unblock device
  remove <dev>               Remove device
  connect <dev>              Connect device
  disconnect <dev>           Disconnect device
  version                    Display version
  quit                       Quit program
```

sudo rfcomm bind /dev/rfcomm0 40:40
