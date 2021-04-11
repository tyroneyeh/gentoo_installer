#!/bin/bash

#
# Create by Tyrone Yeh @ 20210402
# The file URL: wget https://git.io/JY1BT -O install_gentoo.sh
#

# ----- Settings -----
export servername=gentooserver
export timezone="Asia/Taipei"
export systype=amd64 # amd64, amd64-systemd
export useflag="bindist dbus -bluetooth -llvm -video_cards_radeon -video_cards_radeonsi"
export installjobs=3
export python_targets="python3_8"
export video_cards"virtualbox vmware" # Ref. https://wiki.gentoo.org/wiki/Xorg/Guide
export root_partitionsize="80%" # 80% root, 20% swap
export mirrorsite=http://gentoo.cs.nctu.edu.tw/gentoo-distfiles # Ref. https://www.gentoo.org/downloads/mirrors/
# --------------------

set -e

if [ ! -f .local/bin/pip ]; then
    wget https://bootstrap.pypa.io/get-pip.py
    python get-pip.py
    python -m pip install ansible
fi

if [ ! -f gentoo_install.yml ]; then
    wget https://git.io/JY10E -O gentoo_install.yml
fi

if [ "$systype" = "amd64" ]; then
    .local/bin/ansible-playbook --skip-tags "systemd" gentoo_install.yml
else
    .local/bin/ansible-playbook --skip-tags "openrc" gentoo_install.yml
fi

if [ -f /mnt/gentoo/sbin/openrc-run ]; then
    if [ ! -f /mnt/gentoo/etc/init.d/net.eth0 ]; then
        chroot /mnt/gentoo bash -c "ln -s /etc/init.d/net.lo /etc/init.d/net.eth0"
    fi
    chroot /mnt/gentoo bash -c "rc-update add net.eth0"
    chroot /mnt/gentoo bash -c "rc-update add sshd"
else
    chroot /mnt/gentoo bash -c "systemctl enable NetworkManager"
    chroot /mnt/gentoo bash -c "systemctl enable sshd"
fi

echo -e "\nSet root password:"
chroot /mnt/gentoo bash -c passwd

read -p "Input your username for create new user: " username
if [ ! -d /mnt/gentoo/home/$username ]; then
    echo "Add user $username"
    chroot /mnt/gentoo bash -c "useradd -m $username"
fi

echo "Set $username password"
chroot /mnt/gentoo bash -c "passwd $username"

echo "Add gentoo user to sudoers"
chroot /mnt/gentoo bash -c "gpasswd -a $username wheel"
chroot /mnt/gentoo bash -c "gpasswd -a $username tty"
chroot /mnt/gentoo bash -c "gpasswd -a $username audio"
chroot /mnt/gentoo bash -c "gpasswd -a $username video"
chroot /mnt/gentoo bash -c "gpasswd -a $username users"

echo "Congratulations! your Gentoo installed, please [reboot] then eject CD."
