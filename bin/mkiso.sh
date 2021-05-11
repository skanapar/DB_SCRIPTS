#!/bin/csh
# script to create iso
# $1 is the iso file
# $2 is the path
# example: createiso /tmp/test.iso .
sudo mkisofs -R -J -v -A "volume name" -o $1 $2
