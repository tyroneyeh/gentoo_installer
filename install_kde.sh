#!/bin/bash

#
# Create by Tyrone Yeh @ 20210402
# The file URL https://git.io/JY1ER
#

systemctl=`which systemctl`
systemd=0
if [ $? -eq 0 ]; then
    systemd=1
    eselect profile set default/linux/amd64/17.1/desktop/plasma/systemd
else
    eselect profile set default/linux/amd64/17.1/desktop/plasma
fi

set -e

if [ "`grep -o llvm /etc/portage/package.mask/customs`" = "" ]; then
    echo sys-level/llvm >> /etc/portage/package.mask/customs
    echo sys-level/llvm-common >> /etc/portage/package.mask/customs
fi

emerge plasma-meta sddm kdecore-meta
emerge -uDN world

sed -i 's/"xdm"/"sddm"/' /etc/conf.d/xdm

if [ $systemd -eq 1 ]; then
    systemctl enable xdm
    systemctl enable dbus
    systemctl enable NetworkManager
    systemctl restart xdm
else
    rc-update add xdm
    rc-update add dbus
    rc-update add NetworkManager
    rc-service xdm restart
fi

