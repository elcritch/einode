# build under OTP 17.1 on Linux
# -lsocket should be added and -lrt should be removed while build on FreeBSD

ERTS=$(shell elixir ../erl_base.exs)
INCLUDE_DIR=$(ERTS)/include
LIB_DIR=$(ERTS)/lib

all: cserver cserver2 cserver_ei3 cclient nim

cserver:
	gcc -o cserver \
		-Wno-implicit-function-declaration \
		-Wno-deprecated-declarations \
		-I$(INCLUDE_DIR) -L$(LIB_DIR) \
		complex.c cnode_s.c \
		-lerl_interface -lei -lpthread

cserver2:
	gcc -o cserver2 \
		-Wno-implicit-function-declaration \
		-Wno-deprecated-declarations \
		-I$(INCLUDE_DIR) -L$(LIB_DIR) \
		complex.c cnode_s2.c \
		-lerl_interface -lei -lpthread

cserver_ei3:
	gcc -o cserver_ei3 \
		-Wno-implicit-function-declaration \
		-I$(INCLUDE_DIR) -L$(LIB_DIR) \
		complex.c cnode_ei_s2.c \
		-lerl_interface -lei -lpthread

cclient:
	gcc -o cclient \
		-Wno-implicit-function-declaration \
		-Wno-deprecated-declarations \
		-I$(INCLUDE_DIR) -L$(LIB_DIR) \
		complex.c cnode_c.c \
		-lerl_interface -lei -lpthread

nim_server4:
	nim c --d:debug \
		--passC=-I"$(INCLUDE_DIR)" \
		--passL=-L"$(LIB_DIR) -lerl_interface -lei -lpthread " \
		--debugger:native \
		cnode_ei_s3.nim 

		# -d:traceArc \

nim_client4:
	nim c --d:debug \
		--gc:arc \
		--passC=-I"$(INCLUDE_DIR)" \
		--passL=-L"$(LIB_DIR) -lerl_interface -lei -lpthread " \
		--debugger:native \
		cnode_ei_server4.nim 

nim_s5:
	nim c --d:debug \
		--gc:arc \
		--passC=-I"$(INCLUDE_DIR)" \
		--passL=-L"$(LIB_DIR) -lerl_interface -lei -lpthread " \
		--debugger:native \
		cnode_ei_client4.nim 


clean:
	rm -Rf cclient cserver cserver2 cnode_ei_client4 cnode_ei_server4
	rm -Rf cclient cnode_ei_s3 cnode_ei_s4 cnode_ei_s5 cserver cserver2 cserver_ei3
