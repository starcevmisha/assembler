#!/bin/sh
set	-eu
as -o $1.o $1.s -acmhls=$1.lst -g
ld -o $1 $1.o
