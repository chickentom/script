#!/bin/sh
temp=$(LC_ALL=C lscpu |grep Virtualization)
echo $temp
if [ "$temp"=="Virtualization: VT-x" ] || [ "$temp"=="Virtualization: AMD-V" ];then 
    echo "Your PC is not compatable or you haven't enabled Virtualization Support"
    exit
fi
echo "Hallo"
exit