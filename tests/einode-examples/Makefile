# build under OTP 17.1 on Linux
# -lsocket should be added and -lrt should be removed while build on FreeBSD

ERTS=$(shell elixir ../erl_base.exs)
INCLUDE_DIR=$(ERTS)/include
LIB_DIR=$(ERTS)/lib

all: cserver cserver2 cserver_ei3 cclient nim

## Should move these to use rules, but ain't nobody got time 
nim_server1:
	nim c --d:debug \
		--passC=-I"$(INCLUDE_DIR)" \
		--passL=-L"$(LIB_DIR) -lerl_interface -lei -lpthread " \
		--debugger:native \
		cnode_ei_server1.nim 

		# -d:traceArc \

nim_server2:
	nim c --d:debug \
		--gc:arc \
		--passC=-I"$(INCLUDE_DIR)" \
		--passL=-L"$(LIB_DIR) -lerl_interface -lei -lpthread " \
		--debugger:native \
		cnode_ei_server2.nim 

nim_client2:
	nim c --d:debug \
		--gc:arc \
		--passC=-I"$(INCLUDE_DIR)" \
		--passL=-L"$(LIB_DIR) -lerl_interface -lei -lpthread " \
		--debugger:native \
		cnode_ei_client2.nim 


clean:
	rm -Rf cclient cserver cserver2 cnode_ei_server3 cnode_ei_client4 cnode_ei_server4
	rm -Rf cclient cnode_ei_s3 cnode_ei_s4 cnode_ei_s5 cserver cserver2 cserver_ei3
	rm -Rf *.dSYM # macos
