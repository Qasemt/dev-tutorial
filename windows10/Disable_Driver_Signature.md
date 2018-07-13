#### How to Disable Driver Signature Verification on 64-Bit Windows 8 or 10 (So That You Can Install Unsigned Drivers)
link1

``` console
Option One: Enable Test Signing Mode
bcdedit /set testsigning on
bcdedit /set testsigning off
and reset pc (shift)
```
``` bash
Option Two: Use an Advanced Boot Option
 hold down the Shift key while you click the “Restart” option in Windows
```
