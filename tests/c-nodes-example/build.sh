# build under OTP 17.1 on Linux
# -lsocket should be added and -lrt should be removed while build on FreeBSD

set -x
set -e

INCLUDE_DIR=/Users/elcritch/.asdf/installs/erlang/22.2.1//usr/include/
LIB_DIR=/Users/elcritch/.asdf/installs/erlang/22.2.1//lib/erl_interface-3.13.1/lib

gcc -o cserver \
	-Wno-implicit-function-declaration \
	-Wno-deprecated-declarations \
	-I$INCLUDE_DIR -L$LIB_DIR \
	complex.c cnode_s.c \
	-lerl_interface -lei 

gcc -o cserver2 \
	-Wno-implicit-function-declaration \
	-Wno-deprecated-declarations \
	-I$INCLUDE_DIR -L$LIB_DIR \
	complex.c cnode_s2.c \
	-lerl_interface -lei 

gcc -o cserver_ei3 \
	-Wno-implicit-function-declaration \
	-I$INCLUDE_DIR -L$LIB_DIR \
	complex.c cnode_ei_s2.c \
	-lerl_interface -lei 

gcc -o cclient \
	-Wno-implicit-function-declaration \
	-Wno-deprecated-declarations \
	-I$INCLUDE_DIR -L$LIB_DIR \
	complex.c cnode_c.c \
	-lerl_interface -lei 

