#!/bin/bash

echo '(c) by Tobias Schramm 2014'

ROOTUID=0

if [ "$UID" -ne "$ROOTUID" ]
then
  echo You must be root to execute this script.
  exit
fi

read -p 'Do you wish to commit your changes to /var and /home? [Y/n]' yn
case $yn in
  [Yy]* ) ;;
  * ) echo Filesystem remains unchanged; exit;;
esac

echo Creating backup of current data

if [ -d /var.backup1 ]
then
  echo Removing old, obsolete backup of /var
  rm -rf /var.backup1
fi

if [ -d /home.backup1 ]
then
  echo Removing old, obsolete backup of /home
  rm -rf /home.backup1
fi

if [ -d /var.backup ]
then
  echo Creating backup of /var.backup
  mv /var.backup /var.backup1
fi

if [ -d /home.backup ]
then
  echo Creating backup of /home.backup
  mv /home.backup /home.backup1
fi

echo Backupping /var
cp -rp /var /var.backup

echo Backupping /home
cp -rp /home /home.backup

echo Removing old /var
rm -rf /ro/var/*

echo Removing old /home
rm -rf /ro/home/*

echo Comitting changed data from /var
cp -rp /var.backup/* /ro/var/

echo Comitting chnaged data from /home
cp -rp /home.backup/* /ro/home/

echo Done.
