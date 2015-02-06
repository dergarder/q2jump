# makefile for jump

# ----------------------------------------------------- #
# Makefile for the CTF game module for Quake II         #
#                                                       #
# Just type "make" to compile the                       #
#  - CTF Game (game.so / game.dll)                      #
#                                                       #
# Dependencies:                                         #
# - None, but you need a Quake II to play.              #
#   While in theorie every one should work              #
#   Yamagi Quake II ist recommended.                    #
#                                                       #
# Platforms:                                            #
# - FreeBSD                                             #
# - Linux                                               #
# - Mac OS X                                            #
# - OpenBSD                                             #
# - Windows                                             # 
# ----------------------------------------------------- #

# Detect the OS
ifdef SystemRoot
OSTYPE := Windows
else
OSTYPE := $(shell uname -s)
endif
 
# Special case for MinGW
ifneq (,$(findstring MINGW,$(OSTYPE)))
OSTYPE := Windows
endif
 
# Detect the architecture
ifeq ($(OSTYPE), Windows)
# At this time only i386 is supported on Windows
ARCH := i386
else
# Some platforms call it "amd64" and some "x86_64"
ARCH := $(shell uname -m | sed -e s/i.86/i386/ -e s/amd64/x86_64/)
endif

# Refuse all other platforms as a firewall against PEBKAC
# (You'll need some #ifdef for your unsupported  plattform!)
ifeq ($(findstring $(ARCH), i386 x86_64 sparc64),)
$(error arch $(ARCH) is currently not supported)
endif

# ----------

# Base CFLAGS. 
#
# -O2 are enough optimizations.
# 
# -fno-strict-aliasing since the source doesn't comply
#  with strict aliasing rules and it's next to impossible
#  to get it there...
#
# -fomit-frame-pointer since the framepointer is mostly
#  useless for debugging Quake II and slows things down.
#
# -g to build allways with debug symbols. Please do not
#  change this, since it's our only chance to debug this
#  crap when random crashes happen!
#
# -fPIC for position independend code.
#
# -MMD to generate header dependencies.
ifeq ($(OSTYPE), Darwin)
CFLAGS := -O2 -fno-strict-aliasing -fomit-frame-pointer \
		  -Wall -pipe -g -arch i386 -arch x86_64 
else
CFLAGS := -O2 -fno-strict-aliasing -fomit-frame-pointer \
		  -Wall -pipe -g -MMD
endif

# ----------

# Base LDFLAGS.
ifeq ($(OSTYPE), Darwin)
LDFLAGS := -shared -arch i386 -arch x86_64 
else
LDFLAGS := -shared
endif

# ----------

# Builds everything
all: game

# ----------
 
# When make is invoked by "make VERBOSE=1" print
# the compiler and linker commands.

ifdef VERBOSE
Q :=
else
Q := @
endif

# ----------

# Phony targets
#.PHONY : all clean ctf

# ----------
 
# Cleanup
clean:
	@echo "===> CLEAN"
	${Q}rm -Rf build release
 
# ----------

# The ctf game
ifeq ($(OSTYPE), Windows)
game:
	@echo "===> Building game.dll"
	$(Q)mkdir -p release
	$(MAKE) release/game.dll

build/%.o: %.c
	@echo "===> CC $<"
	$(Q)mkdir -p $(@D)
	$(Q)$(CC) -c $(CFLAGS) -o $@ $<
else
game:
	@echo "===> Building game.so"
	#$(Q)mkdir -p release
	$(MAKE) game.so

build/%.o: %.c
	@echo "===> CC $<"
	$(Q)mkdir -p $(@D)
	$(Q)$(CC) -c $(CFLAGS) -o $@ $<

game.so : CFLAGS += -fPIC
endif
 
# ----------

GAME_OBJS = \
g_chase.o \
g_cmds.o \
g_combat.o \
g_func.o \
g_items.o \
g_main.o \
g_misc.o \
g_phys.o \
g_save.o \
g_spawn.o \
g_svcmds.o \
g_target.o \
g_trigger.o \
g_utils.o \
p_client.o \
p_hud.o \
p_view.o \
q_shared.o

# ----------

# Rewrite pathes to our object directory
GAME_OBJS = $(patsubst %,build/%,$(GAME_OBJS_))

# ----------

# Generate header dependencies
CTF_DEPS= $(GAME_OBJS:.o=.d)

# ----------

# Suck header dependencies in
-include $(CTF_DEPS)

# ----------

ifeq ($(OSTYPE), Windows)
release/game.dll : $(GAME_OBJS)
	@echo "===> LD $@"
	$(Q)$(CC) $(LDFLAGS) -o $@ $(GAME_OBJS)
else
release/game.so : $(GAME_OBJS)
	@echo "===> LD $@"
	$(Q)$(CC) $(LDFLAGS) -o $@ $(GAME_OBJS)
endif
 
# ----------
