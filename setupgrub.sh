#!/bin/bash

echo '(c) by Tobas Schramm 2014'

GRUBPSW='12345'

ROOTUID=0

if [ "$UID" -ne "$ROOTUID" ]
then
  echo You must be root to execute this script.
  exit
fi

DESCR_LOC='/etc/grub.d/'
DESCR_STD=$DESCR_LOC'10_linux'
DESCR_HEADER=$DESCR_LOC'00_header'

echo
echo "Disabling security for standard boot entry"
sed -i "s/menuentry '\${title}' \${CLASS}/menuentry '\${title}' \${CLASS} --unrestricted/g" $DESCR_STD

echo "Setting boot password"
echo 'cat << EOF' >> $DESCR_HEADER
echo 'set superusers="tobias"' >> $DESCR_HEADER
echo 'set password tobias '$GRUBPSW >> $DESCR_HEADER
echo 'EOF' >> $DESCR_HEADER

echo Disabling boot failure check
sed -i "s/set timeout=\${GRUB_RECORDFAIL_TIMEOUT:--1}/set timeout=\${2}/g" $DESCR_HEADER
sed -i "s/set recordfail=1/set recordfail=0/g" $DESCR_HEADER

echo Updating grub
update-grub

echo Done.

