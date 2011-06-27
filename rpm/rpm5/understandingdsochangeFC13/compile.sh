#!/bin/sh
set -eu
###########
# Retrieved from
#    https://fedoraproject.org/wiki/UnderstandingDSOLinkChange
#Prepare position-independent code:

gcc -g -fPIC -c foo1.c foo2.c foo3.c

#Generate foo3.so:

gcc -shared -o foo3.so foo3.o

#Generate foo2.so, linking foo3.so:

gcc -shared -o foo2.so foo2.o foo3.so 
###################################

#Current

#A call to gcc will succeed quietly, even though the link to foo3.so is only implicit.

 gcc -o foo1 foo1.o foo2.so -Wl,--rpath-link=.
####################################


