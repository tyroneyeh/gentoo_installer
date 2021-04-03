#!/bin/bash

#
# Create by Tyrone Yeh @ 20210402
# The file URL https://git.io/JY1ER
#

systemctl=`which systemctl`
systemd=$?
if [ $systemd -eq 1 ]; then
    eselect profile set default/linux/amd64/17.1/desktop/plasma/systemd
else
    eselect profile set default/linux/amd64/17.1/desktop/plasma
fi

set -e

if [ ! -f /etc/portage/package.mask/customs -o "`grep -o llvm /etc/portage/package.mask/customs`" = "" ]; then
    echo sys-level/llvm >> /etc/portage/package.mask/customs
    echo sys-level/llvm-common >> /etc/portage/package.mask/customs
fi

if [ ! -f /etc/portage/package.use/customs -o "`grep -o libdrm /etc/portage/package.use/customs`" = "" ]; then
    echo x11-libs/libdrm libkms >> /etc/portage/package.use/customs
    echo media-libs/mesa xa >> /etc/portage/package.use/customs
    echo sys-apps/dbus user-session >> /etc/portage/package.use/customs
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

