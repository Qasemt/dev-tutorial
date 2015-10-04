
##### Cubies Board 
**A10 :**
 CFLAGS="-O2 -g0 -pipe -mcpu=cortex-a8 -mfloat-abi=hard -mfpu=neon -mthumb"
**A20 :**
 CFLAGS="-O3 -march=armv7-a -mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard"
### BBB 
QMAKE_CFLAGS_RELEASE="-O3 -march=armv7-a -mtune=cortex-a8 -mfpu=neon -mfloat-abi=hard"
QMAKE_CXXFLAGS_RELEASE="-O3 -march=armv7-a -mtune=cortex-a8 -mfpu=neon -mfloat-abi=hard"
### Raspberry pi
QMAKE_CFLAGS_RELEASE="-O3 -march=armv6j -mtune=arm1176jzf-s -mfpu=vfp -mfloat-abi=hard"
QMAKE_CXXFLAGS_RELEASE="-O3 -march=armv6j -mtune=arm1176jzf-s -mfpu=vfp -mfloat-abi=hard"
