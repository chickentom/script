#!/bin/bash
temp=$(LC_ALL=C lscpu |grep Virtualization)
OS=$(lsb_release -a)
echo $temp
echo $OS
if [[ $temp == *VT-x* || $temp == *AMD* ]];
then 
    echo "Your PC is compatable"
    if [$OS == *"lsb_release -a"*] then
    echo "and your are runnin Ubuntu"
    exit
    fi
else
    echo "Your Pc is not compatable"
fi
exit
