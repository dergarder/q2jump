ARCH := $(shell uname -m | sed -e s/i.86/i386/ -e s/sun4u/sparc64/ -e s/arm.*/arm/ -e s/sa110/arm/ -e s/alpha/axp/)

CFLAGS=-O -g -fPIC -Wall

game_SRC:=g_chase.c g_cmds.c g_combat.c g_func.c g_items.c g_main.c g_misc.c g_phys.c g_save.c g_spawn.c g_svcmds.c g_target.c g_trigger.c g_utils.c p_client.c p_hud.c p_view.c q_shared.c

game_OBJ:=$(game_SRC:.c=.o)

ALLSRC:=$(game_SRC)

.PHONY: default clean

default: game$(ARCH).so

TARGETS:=game$(ARCH).so

game$(ARCH).so: $(game_OBJ)
	$(CC) -shared -o $@ $^ $(LDFLAGS)

clean:
	rm -f *.o game$(ARCH).so
