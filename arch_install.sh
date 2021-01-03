#!/bin/bash

# Archlinux installation script for thinkpad x1c

# Enable ssh
# https://unix.stackexchange.com/questions/352139/how-to-setup-ssh-access-to-arch-linux-iso-livecd-booted-computer

# Set console font
setfont /usr/share/kbd/consolefonts/LatGrkCyr-12x22.psfu.gz

# Ensure the system clock is accurate
timedatectl set-ntp true

#Format the disc
mkfs.ext4 /dev/sda3

#Mount the home
mount /dev/sda3 /mnt

mirror1='Server = https://mirrors.cloud.tencent.com/archlinux/$repo/os/$arch'
mirror2='Server = https://mirrors.aliyun.com/archlinux/$repo/os/$arch'
mirror3='Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch'
mirror4='Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch'
mirror5='Server = https://mirrors.zju.edu.cn/archlinux/$repo/os/$arch'
sed -i "1i $mirror5" /etc/pacman.d/mirrorlist
sed -i "1i $mirror4" /etc/pacman.d/mirrorlist
sed -i "1i $mirror3" /etc/pacman.d/mirrorlist
sed -i "1i $mirror2" /etc/pacman.d/mirrorlist
sed -i "1i $mirror1" /etc/pacman.d/mirrorlist
curl https://gitee.com/toyohama/arch_install/raw/master/archlinuxmirrorlist  > /etc/pacman.d/mirrorlist

# Install base, linux, linux-firmware packages and base-devel package groups
pacstrap /mnt base base-devel linux linux-firmware dhcpcd

# Generate an fstab file
genfstab -L /mnt >> /mnt/etc/fstab

# Configure the system
cat << EOF | arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc
sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen
sed -i "s/#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g" /etc/locale.gen
sed -i "s/#zh_HK.UTF-8 UTF-8/zh_HK.UTF-8 UTF-8/g" /etc/locale.gen
sed -i "s/#zh_TW.UTF-8 UTF-8/zh_TW.UTF-8 UTF-8/g" /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 >> /etc/locale.conf
echo "arch" >> /etc/hostname
echo root:' ' | chpasswd
pacman -S --noconfirm xorg plasma dolphin kate kdialog keditbookmarks kfind khelpcenter kwrite ark gwenview grub nano git wget konsole networkmanager sddm os-prober ntfs-3g noto-fonts-cjk bluez bluez-utils pulseaudio-bluetooth
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
useradd -m -G wheel toy
echo toy:' ' | chpasswd
sed -i "s/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g" /etc/sudoers
systemctl enable sddm
systemctl enable NetworkManager
systemctl enable bluetooth.service
echo -e 'load-module module-bluetooth-policy\nload-module module-bluetooth-discover' >> /etc/pulse/system.pa
curl https://gitee.com/toyohama/arch_install/raw/master/archlinuxcnmirrorlist >> /etc/pacman.conf
pacman -Sy --noconfirm archlinuxcn-keyring
pacman -S --noconfirm yay
sed -i "s/#UseSyslog/UseSyslog/g" /etc/pacman.conf
sed -i "s/#Color/Color/g" /etc/pacman.conf
sed -i "s/#TotalDownload/TotalDownload/g" /etc/pacman.conf
sed -i "s/#CheckSpace/CheckSpace/g" /etc/pacman.conf
sed -i "s/#VerbosePkgLists/VerbosePkgLists/g" /etc/pacman.conf
sed -i "s/#[multilib]/[multilib]/g"  /etc/pacman.conf

yay -Sy --noconfirm pamac-aur firefox v2raya google-chrome fcitx-qt4 fcitx-qt5 fcitx-configtool xsettingsd visual-studio-code-bin netease-cloud-music wps-office-cn ttf-wps-fonts wps-office-mui-zh-cn
dd if=/dev/zero of=/swapfile bs=1M count=4096 status=progress 
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo /swapfile none swap defaults 0 0 >> /etc/fstab
EOF

# Unmount
umount -R /mnt

reboot

# Enjoy