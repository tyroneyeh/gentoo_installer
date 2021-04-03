#!/bin/bash

#
# Create by Tyrone Yeh @ 20210402
#

systemctl=`which systemctl`
if [ $? -eq 0 ]; then
    eselect profile set default/linux/amd64/17.1/desktop/plasma/systemd
else
    eselect profile set default/linux/amd64/17.1/desktop/plasma
fi

if [ "`grep -o llvm /etc/portage/package.mask/customs`" = "" ]; then
    echo sys-level/llvm >> /etc/portage/package.mask/customs
    echo sys-level/llvm-common >> /etc/portage/package.mask/customs
fi

emerge plasma-meta sddm kdecore-meta
emerge -uDN world

sed -i 's/"xdm"/"sddm"/' /etc/conf.d/xdm
rc-update add xdm
rc-service xdm restart
# # wget https://github.com/.../gentoo_kde.yml
# .local/bin/ansible-playbook gentoo_kde.yml
