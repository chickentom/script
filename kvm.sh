#!/bin/bash
temp=$(LC_ALL=C lscpu |grep Virtualization)
echo $temp

if [[ $temp == *VT-x* || $temp == *AMD* ]];
then 
    echo "Your PC is not compatable or you haven't enabled Virtualization Support"
    exit
fi
echo "Hallo"
exit