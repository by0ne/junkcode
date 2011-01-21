#!/bin/sh

gcc -O2 -c mymemcpy.c
ld -G --build-id mymemcpy.o -o mymemcpy.so
