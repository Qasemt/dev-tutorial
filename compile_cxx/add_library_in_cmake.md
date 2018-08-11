

```
sudo apt-get install imagemagick
sudo apt-get install cmake libmagick++-dev
```

### LD_LIBRARY_PATH config 
export LD_LIBRARY_PATH="/home/xxx/workspace/libs/Image_magick/lib:$LD_LIBRARY_PATH"
## baray library hay ke bedone ld add shodan bayad vs code zaman ejray launcher in tor config shavad.

### for debug in vs code file launch.json

``` json
{
    "version": "0.2.0",
    "configurations": [

       {
            "name": "UNIX_DEBUG_RUN",
            "type": "cppdbg",
            "request": "launch",
            "program": "${workspaceFolder}/bin/test_magick",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}",
            "environment": [
                {
                    "name": "LD_LIBRARY_PATH",
                    "value": "../libs/Image_magick/lib"
                }
            ],
            "externalConsole": true,
            "MIMode": "gdb",
            
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true,
                    ""
                }
            ],
            "preLaunchTask": "🔨 unix_build_debug",
        },
    ]
}

```


### cmake config

``` 
cmake_minimum_required (VERSION 3.0.0)
include ( CheckIncludeFiles )
project (test_magick)

if (CMAKE_CXX_COMPILER_ID MATCHES "GNU")

#export LD_LIBRARY_PATH="/home/xxx/workspace/libs/Image_magick/lib:$LD_LIBRARY_PATH"

set(rr  "/home/taheri/workspace/libs/Image_magick/lib")
#check_include_files (netdb.h HAVE_NETDB_H)
set(MYOUTDIR "./../bin/")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${MYOUTDIR}" )
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -Wno-Wunused-parameter -lm")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}   -D_DEBUG  -Wall -Wno-Wunused-parameter   -lm")

# set (CMAKE_C_FLAGS_DEUG "-std=c99 ${CMAKE_C_FLAGS}")
SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99 -g -D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE -D_POSIX_C_SOURCE")
endif()


#file(MAKE_DIRECTORY "./mybuild/build_debug/")
#file(MAKE_DIRECTORY "./mybuild/build_release/")

#__________________________ the shared library:

link_directories( "${rr}")



include_directories ( "." "/home/taheri/workspace/libs/Image_magick/include/ImageMagick-6/")
#_______ ADD SOURCES 
# set (PRG_SOURCE  "teamyar.cpp" 
                  
#                  "sources/fastcgi/fcgi_stdio.c" /
#                  "sources/fastcgi/fcgiapp.c" /
#                  "sources/fastcgi/fcgio.cpp" /
#                  "sources/fastcgi/os_unix.c")

#
#"sources/sql/main_unix.cpp" /
#"sdk/Bases/BinFile.h"
file(GLOB PRG_SOURCE "main.cpp"
               )
  
 add_definitions( -DMAGICKCORE_QUANTUM_DEPTH=16 )
 add_definitions( -DMAGICKCORE_HDRI_ENABLE=0 )
#set(CMAKE_INSTALL_RPATH "${rr}")
 # set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
               
#_______ CREATE EXE
add_executable (${PROJECT_NAME} ${PRG_SOURCE} )
#____ 



#______ SET LIBRARY DYNAMIC AND STATIC 
 #set(rr  "/home/taheri/Downloads/ImageMagick-x86_64-pc-linux-gnu/ImageMagick-6.9.2/lib")
 #link_directories( "${rr}")
 #target_link_libraries(${PROJECT_NAME}  "${rr}/libMagickCore-6.Q16.so"   "${rr}/libMagick++-6.Q16.so"   "${rr}/libMagickWand-6.Q16.so" )
 #------------------------------ cmake solution
# find_package(ImageMagick COMPONENTS Magick++)
# include_directories(${ImageMagick_INCLUDE_DIRS})
# target_link_libraries(${PROJECT_NAME}  ${ImageMagick_LIBRARIES} ${PROJECT_LINK_SHARED_LIBS}   -lpthread  -fPIC)
#------------------------------  solution 3----


 target_link_libraries(${PROJECT_NAME}   ${PROJECT_LINK_SHARED_LIBS}  "${rr}/libMagick++-6.Q16.so" "${rr}/libMagickCore-6.Q16.so" "${rr}/libMagickWand-6.Q16.so"   -lpthread  -fPIC)

```
