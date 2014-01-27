#!/bin/bash

echo '(c) by Tobias Schramm 2014'

ROOTUID=0

if [ "$UID" -ne "$ROOTUID" ]
then
  echo You must be root to execute this script.
  exit
fi

mount / -o remount,rw
