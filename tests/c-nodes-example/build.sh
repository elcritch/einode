# build under OTP 17.1 on Linux
# -lsocket should be added and -lrt should be removed while build on FreeBSD

set -x
set -e

ERTS=$( elixir ../erl_base.exs )
INCLUDE_DIR=$ERTS/include
LIB_DIR=$ERTS/lib

gcc -o cserver \
	-Wno-implicit-function-declaration \
	-Wno-deprecated-declarations \
	-I$INCLUDE_DIR -L$LIB_DIR \
	complex.c cnode_s.c \
	-lerl_interface -lei -lpthread

gcc -o cserver2 \
	-Wno-implicit-function-declaration \
	-Wno-deprecated-declarations \
	-I$INCLUDE_DIR -L$LIB_DIR \
	complex.c cnode_s2.c \
	-lerl_interface -lei -lpthread

gcc -o cserver_ei3 \
	-Wno-implicit-function-declaration \
	-I$INCLUDE_DIR -L$LIB_DIR \
	complex.c cnode_ei_s2.c \
	-lerl_interface -lei -lpthread

gcc -o cclient \
	-Wno-implicit-function-declaration \
	-Wno-deprecated-declarations \
	-I$INCLUDE_DIR -L$LIB_DIR \
	complex.c cnode_c.c \
	-lerl_interface -lei -lpthread

nim c --d:debug cnode_ei_s3.nim

