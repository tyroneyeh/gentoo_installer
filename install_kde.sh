#!/bin/bash

#
# Create by Tyrone Yeh @ 20210402
# The file URL: wget https://git.io/JY1ER -O install_kde.sh
#

if [ $USER != "root" ]; then
    echo Please use [sudo sh install_kde.sh]
    exit
fi

systemctl=`which systemctl`
nonsystemd=$?
if [ $nonsystemd -eq 0 ]; then
    eselect profile set default/linux/amd64/17.1/desktop/plasma/systemd
else
    eselect profile set default/linux/amd64/17.1/desktop/plasma
fi

set -e

if [ ! -f /etc/portage/package.mask/customs -o "`grep -o llvm /etc/portage/package.mask/customs`" = "" ]; then
    echo sys-devel/llvm >> /etc/portage/package.mask/customs
    echo sys-devel/llvm-common >> /etc/portage/package.mask/customs
fi

if [ ! -f /etc/portage/package.use/customs -o "`grep -o libdrm /etc/portage/package.use/customs`" = "" ]; then
    echo x11-libs/libdrm libkms >> /etc/portage/package.use/customs
    echo media-libs/mesa xa >> /etc/portage/package.use/customs
    echo sys-apps/dbus user-session >> /etc/portage/package.use/customs
fi

if [ ! -f /etc/portage/package.mask/notbinpkgs ]; then
    eix-update
    EIX_LIMIMT=0 eix -# "\-bin$" | awk -F "/" '{gsub("-bin", "", $2);print $1"/"$2}' >> /etc/portage/package.mask/notbinpkgs
fi

if [ ! -d /var/db/pkg/kde-plasma -o ! -d /var/db/pkg/kde-apps/kdecore-meta ]; then
    emerge plasma-meta sddm kdecore-meta
fi

emerge -uDN world

sed -i 's/"xdm"/"sddm"/' /etc/conf.d/xdm

if [ $nonsystemd -eq 0 ]; then
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
