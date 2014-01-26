#!/bin/bash

echo '(c) by Tobas Schramm 2014'

bash setupgrub.sh
bash mkro.sh sda1 sda5 256M 256M 64M 16M true
