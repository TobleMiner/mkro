#!/bin/bash

echo '(c) by Tobias Schramm 2014'

FALSE="false"
TRUE="true"

function uuid
{
  echo $(blkid /dev/$1 | grep -o '[0-9a-fA-F]\{8\}-[0-9a-fA-F]\{4\}-[0-9a-fA-F]\{4\}-[0-9a-fA-F]\{4\}-[0-9a-fA-F]\{12\}')
}

ROOTUID=0

if [ "$UID" -ne "$ROOTUID" ]
then
  echo You must be root to execute this script.
  exit
fi

if [ -z "$(grep 'tmpfs' '/proc/filesystems')" ]
then
  echo 'Support for tmpfs is not enabled/available in your kernel.'
  echo 'Aborting'
  exit 1
fi

sda_main=${1-sda1}
sda_swap=${2-sda5}
var_size=${3-256M}
home_size=${4-256M}
tmp_size=${5-64M}
media_size=${6-16M}
noprompt=${7-$FALSE}

uff_installed=$(dpkg --list | grep unionfs-fuse)

echo $sda_main will be configured as redonly
echo $sda_swap will be configured to swap
echo 'tmpfs for /var will have a size of '$var_size
echo 'tmpfs for /home will have a size of '$home_size
echo 'tmpfs for /tmp will have a size of '$tmp_size
echo 'tmpfs for /media will have a size of '$media_size
if [ -z "$uff_installed" ]
then
  echo Additionally unionfs-fuse will be installed
fi
echo

if [ "$noprompt" != "$TRUE" ]
then
  read -p 'Do you wish to continue? [Y/n]' yn
  case $yn in
    [Y]* ) ;;
    * ) echo Aborting'!'; exit;;
  esac
fi

if [ -z "$uff_installed" ]
then
  echo Installing unionfs-fuse...
  apt-get install unionfs-fuse --yes
  uff_installed=$(dpkg --list | grep unionfs-fuse)
  if [ -z "$uff_installed" ]
  then
    echo "Installation of unionfs-fuse failed!"
    echo "Aborting"
    exit 1
  fi
fi

echo
echo Getting UUIDs

uuid_main=$(uuid $sda_main)
uuid_swap=$(uuid $sda_swap)

echo $sda_main' => UUID='$uuid_main
echo $sda_swap' => UUID='$uuid_swap

echo

echo Backupping /var
cp -rp /var /var.backup
echo Backupping /home
cp -rp /home /home.backup
echo Creating /ro for fusion
mkdir /ro
echo Moving /var
mv /var /ro/
echo Moving /home
mv /home /ro/
echo Cleaning up and creating mountpoints
rm -rf /media
mkdir /home /var /media 
if [ -d /tmp ]
then
  rm -rf /tmp/*
fi
if [ -d /tmpfs ]
then
  rm -rf /tmpfs
fi
mkdir /tmpfs /tmpfs/var /tmpfs/home

FSTAB_LOC="/etc/"
FSTAB=$FSTAB_LOC'fstab'

echo Backupping fstab

cp -p $FSTAB $FSTAB_LOC'fstab.backup'

echo Rewriting fstab
#This code is really, really dangerous!
echo 'UUID='$uuid_main' / ext4 defaults,noatime,ro 0 1' > $FSTAB
echo 'UUID='$uuid_swap' / swap sw 0 0' >> $FSTAB
echo 'tmpfs /tmpfs/var tmpfs defaults,size='$var_size' 0 0' >> $FSTAB
echo 'tmpfs /tmpfs/home tmpfs defaults,size='$home_size' 0 0' >> $FSTAB
echo 'tmpfs /tmp tmpfs defaults,size='$tmp_size' 0 0' >> $FSTAB
echo 'tmpfs /media  tmpfs defaults,size='$media_size' 0 0' >> $FSTAB
echo 'unionfs-fuse#/tmpfs/var=rw:/ro/var=ro /var fuse cow,allow_other,nonempty' >> $FSTAB
echo 'unionfs-fuse#/tmpfs/home=rw:/ro/home=ro /home fuse cow,allow_other' >> $FSTAB

echo fstab rewrite complete

if [ "$noprompt" == "$TRUE" ]
then
  reboot
  exit
fi

read -p 'Reboot now? [y/n]' yn
case $yn in
  [Yy]* ) reboot;;
esac

echo Done.
