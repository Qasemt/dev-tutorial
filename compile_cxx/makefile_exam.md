```makefile
# Makefile 
#
#     make clean
#     make
#     make exec
#
#-----------------------------------------  
# This check will fail if SHELL is explicitly set to a not
# sh-compatible shell. This is not a problem, because configure.bat
# will not do that.


## linux
    #CHK_DIR_EXISTS = test -d
    #CHK_DIR_EXISTS_GLUE = ||
    #MKDIR = mkdir -p
## if windows 
CHK_DIR_EXISTS = IF NOT EXIST
MKDIR = MD


#####
#@ECHO = ON
TARGET = f.exe
DELETE= DEL 
CURTYPE =
MINGW_BASE	= D:/mingw-w64/mingw64/
INCPATH       =  \
	-I"$(MINGW_BASE)lib/gcc/x86_64-w64-mingw32/7.3.0/include/c++/" \
	-I"$(MINGW_BASE)lib/gcc/x86_64-w64-mingw32/7.3.0/include/c++/x86_64-w64-mingw32/" \
	-I"$(MINGW_BASE)lib/gcc/x86_64-w64-mingw32/7.3.0/include/c++/backward/" \
	-I"$(MINGW_BASE)lib/gcc/x86_64-w64-mingw32/7.3.0/include/" \
	-I"$(MINGW_BASE)lib/gcc/x86_64-w64-mingw32/7.3.0/include-fixed/" \
	-I"$(MINGW_BASE)x86_64-w64-mingw32/include/" \
	-I"$(MINGW_BASE)" \

#---------
	
#
# Project files
#
C_SRCS	= 
CPP_SRCS = main.cpp
OBJS =$(CPP_SRCS:.cpp=.o)

# Optimaze Option
# 
CFLAGOPT  = 
CFLAGOPT += -o3 -o

#
# Link-time cc options:
LDFLAGS =

CC  = gcc
CXX = g++
#                                       linker
LN= $(CPP)

#
# Debug build settings
#


#
# Release build settings
#
RELDIR = release
CURTYPE = $(RELDIR)
RELEXE = $(RELDIR)/$(TARGET)
RELOBJS = $(addprefix $(RELDIR)/, $(OBJS))
RELCFLAGS = -Wall  -g   -dndebug  $(CFLAGOPT)

#----------------------------------------------
all: prep release

release: $(RELEXE)

$(RELEXE): $(RELOBJS)
	$(CXX) $(CFLAGS) $(RELCFLAGS)  $(RELEXE)  $^

$(RELDIR)/%.o: %.cpp
	$(CXX) -c  $(CFLAGS) $(RELCFLAGS)   $<
	
# $(RELDIR)/%.o: %.c
	# $(LN) -c $(CFLAGS) $(RELCFLAGS) -o $@ $<

#
# Other rules $(CURDIR)
#
prep: 
	 $(MKDIR) $(RELDIR)
	
	
	
clean:
	DEL /A /F /Q /S "$(CURTYPE)\*.*"
	FOR /D %%p IN ("$(CURTYPE)\*.*") DO RD "%%p" /S /Q

exec:
	./$(TARGET)
  ```
