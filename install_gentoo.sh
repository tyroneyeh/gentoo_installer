#!/bin/bash

#
# Create by Tyrone Yeh @ 20210402
#

if [ ! -f .local/bin/pip ]; then
    wget https://bootstrap.pypa.io/get-pip.py
    python get-pip.py
    python -m pip install ansible
fi

# wget https://github.com/.../gentoo_install.yml
.local/bin/ansible-playbook gentoo_install.yml

if [ -d /mnt/gentoo/lib/systemd ]; then
    chroot /mnt/gentoo bash -c "systemctl enable NetworkManager"
    chroot /mnt/gentoo bash -c "systemctl enable sshd"
else
    chroot /mnt/gentoo bash -c "ln -s /etc/init.d/net.lo /etc/init.d/net.eth0"
    chroot /mnt/gentoo bash -c "rc-update add net.eth0"
    chroot /mnt/gentoo bash -c "rc-update add sshd"
fi

echo -e "\nSet root password"
chroot /mnt/gentoo bash -c passwd

echo "Add gentoo user"
chroot /mnt/gentoo bash -c 'useradd -m gentoon'

echo "Set gentoo password"
chroot /mnt/gentoo bash -c 'passwd gentoo'

echo "Add gentoo user to sudoers"
chroot /mnt/gentoo bash -c 'gpasswd -a gentoo wheel'
chroot /mnt/gentoo bash -c 'gpasswd -a gentoo tty'
chroot /mnt/gentoo bash -c 'gpasswd -a gentoo audio'
chroot /mnt/gentoo bash -c 'gpasswd -a gentoo video'
chroot /mnt/gentoo bash -c 'gpasswd -a gentoo users'

echo "Congratulations! your Gentoo installed, please eject CD and [reboot]."