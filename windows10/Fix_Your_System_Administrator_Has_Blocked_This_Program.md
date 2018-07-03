#### Fix : Your System Administrator Has Blocked This Program. For more information contact your system administrator
##### Source Link :
* https://www.kapilarya.com/fix-the-store-app-is-blocked-in-windows-10

___
#### Method 1 :
1. Press **Win + R** and put regedit in Run dialog box to open Registry Editor 
2. ``` HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft ```
3. Right click on the Microsoft registry key and select **New > Key**. Name the newly created key as WindowsStore.
   In the right pane of WindowsStore key,right click **DisableStoreApps** and  it should have its **Value data set to 0**, which will enable Windows Store on your machine.
________
#### How to Disable Driver Signature Verification on 64-Bit Windows 8 or 10 (So That You Can Install Unsigned Drivers)

[link1](https://www.howtogeek.com/167723/how-to-disable-driver-signature-verification-on-64-bit-windows-8.1-so-that-you-can-install-unsigned-drivers/)

#### Option One: Enable Test Signing Mode
``` console 
bcdedit /set testsigning on
bcdedit /set testsigning off
```

#### Option Two: Use an Advanced Boot Option
``` console 
 hold down the Shift key while you click the “Restart” option in Windows
```
