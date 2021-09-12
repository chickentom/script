#!/bin/bash
temp=$(LC_ALL=C lscpu |grep Virtualization)
OS=$(lsb_release -a)

if [[ $temp == *VT-x* || $temp == *AMD* ]];
then 
    echo "Your PC is compatable"
    if [[ $OS == *Ubuntu* ]];
    then
    echo "and your are runnin Ubuntu"
    exit
    fi
    if [[ $OS == *Manjaro* ]];
    then
    echo "You're runnin Manjaro"
    sudo pacman -S qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat
    sudo pacman -S ebtables iptables
    echo -e "[archlinuxfr]\nSigLevel = Never\nServer = http://repo.archlinux.fr/$arch" >> /etc/pacman.conf
    sudo pacman -Syy
    sudo pacman -S yaourt
    yaourt -S --noconfirm --needed libguestfs
    sudo systemctl enable libvirtd.service
    sudo systemctl start libvirtd.service
    echo "---------------------------------------------"
    
    exit
    fi
else
    echo "Your Pc is not compatable"
fi
exit
