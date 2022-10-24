
#### Requiremnts :
1.download visualgdb VisualGDB_5.2r8 as Downloadly.ir <br>
2.download toolchain **gcc-arm-none-eabi-6-2017-q2-update-win32.exe** -> https://developer.arm.com/open-source/gnu-toolchain/gnu-rm/downloads  <br>
  #### Note :
  ```
  az toolchain khode visualgdb estefade nakonid chon **printf** support nemikone 

  ```
  
#### Config visualGDB :

1.baray inke beshavad rahat config konim type proje ra az noe **GNU MAKE** entekhab konid <br>
2.ba'ad an ,dar folder **Make Files ** 2 file vojod darad <br>
  debug.make va release.make <br>
  in value ra baray support floating (printf,scanf,sprintf) change konid (-mthumb -mcpu=cortex-m0 -mfloat-abi=soft) <br>
  ```
  LDFLAGS := -Wl,-gc-sections, -mthumb -mcpu=cortex-m0 -mfloat-abi=soft 
  ```
