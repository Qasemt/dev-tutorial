### Fix : Your System Administrator Has Blocked This Program. For more information contact your system administrator
### Source Link :
* https://www.kapilarya.com/fix-the-store-app-is-blocked-in-windows-10

___
#### Method 1 :
1. Press **Win + R** and put regedit in Run dialog box to open Registry Editor 
2. ``` HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft ```
3. Right click on the Microsoft registry key and select **New > Key**. Name the newly created key as WindowsStore.
   In the right pane of WindowsStore key,right click **DisableStoreApps** and  it should have its **Value data set to 0**, which will enable Windows Store on your machine.
