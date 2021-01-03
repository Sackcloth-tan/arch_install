#!/bin/bash

# Archlinux installation script

# Enable ssh
# https://unix.stackexchange.com/questions/352139/how-to-setup-ssh-access-to-arch-linux-iso-livecd-booted-computer

# Set console font
setfont /usr/share/kbd/consolefonts/LatGrkCyr-12x22.psfu.gz

# Ensure the system clock is accurate
timedatectl set-ntp true

# Mount home
mkfs.ext4 /dev/sda4
mount /dev/sda4 /mnt

#Mount the boot
mkdir /mnt/boot
mount /dev/sda2 /mnt/boot

# Mirrors
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
#curl https://gitee.com/toyohama/arch_install/raw/master/archlinuxmirrorlist  > /etc/pacman.d/mirrorlist

# Install
pacstrap /mnt \
    base linux linux-firmware grub os-prober efibootmgr btrfs-progs \
    xorg plasma-meta \
    base-devel   # iwd

# Generate fstab file
genfstab -U /mnt >> /mnt/etc/fstab

# Configuration
cat << EOF | arch-chroot /mnt
# Time zone
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc
# Localization
sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen
#sed -i "s/#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g" /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 >> /etc/locale.conf
# Network
echo archlinux >> /etc/hostname
echo -e "127.0.0.1\tlocalhost
::1\t\tlocalhost
127.0.1.1\tarchlinux.localdomain\tarchlinux" >> /etc/hosts
# Keyfile
dd bs=512 count=4 if=/dev/random of=/crypto_keyfile.bin iflag=fullblock
chmod 600 /crypto_keyfile.bin
chmod 600 /boot/initramfs-linux*
echo 1 | cryptsetup luksAddKey /dev/vda2 /crypto_keyfile.bin
sed -i "s|FILES=()|FILES=(/crypto_keyfile.bin)|g"            /etc/mkinitcpio.conf
sed -i "s/ block filesystems / block encrypt filesystems /g" /etc/mkinitcpio.conf
# Regenerate the initramfs
mkinitcpio -P
# Root password
echo root:1 | chpasswd
# GRUB
sed -i "s/quiet//g" /etc/default/grub
sed -i 's|GRUB_CMDLINE_LINUX_DEFAULT="|GRUB_CMDLINE_LINUX_DEFAULT="cryptdevice=/dev/vda2:cryptroot |g' /etc/default/grub
sed -i "s/#GRUB_ENABLE_CRYPTODISK=y/GRUB_ENABLE_CRYPTODISK=y/g"                                        /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
grub-mkconfig -o /boot/grub/grub.cfg
# Me
useradd -m -G wheel -s /bin/zsh toy
echo toy:1 | chpasswd
sed -i "s/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g" /etc/sudoers
pacman -S --noconfirm xorg plasma dolphin kate kdialog keditbookmarks kfind khelpcenter kwrite ark gwenview nano git wget konsole networkmanager sddm os-prober ntfs-3g noto-fonts-cjk bluez bluez-utils pulseaudio-bluetooth
systemctl enable sddm
systemctl enable NetworkManager
systemctl enable bluetooth.service
echo -e 'load-module module-bluetooth-policy\nload-module module-bluetooth-discover' >> /etc/pulse/system.pa
# Internet
echo "[Match]
Name=en*
[Network]
DHCP=yes" >> /etc/systemd/network/20-wired.network
systemctl enable sddm
systemctl enable systemd-networkd
systemctl enable systemd-resolved
#systemctl enable iwd
# archlinuxcn
curl https://gitee.com/toyohama/arch_install/raw/master/archlinuxcnmirrorlist >> /etc/pacman.conf
pacman -Sy --noconfirm archlinuxcn-keyring
# yay
pacman -S  --noconfirm yay
# pacman
sed -i "s/#UseSyslog/UseSyslog/g"             /etc/pacman.conf
sed -i "s/#Color/Color/g"                     /etc/pacman.conf
sed -i "s/#TotalDownload/TotalDownload/g"     /etc/pacman.conf
sed -i "s/#CheckSpace/CheckSpace/g"           /etc/pacman.conf
sed -i "s/#VerbosePkgLists/VerbosePkgLists/g" /etc/pacman.conf
yay -Sy --noconfirm pamac-aur firefox v2raya google-chrome fcitx-qt4 fcitx-qt5 fcitx-configtool xsettingsd visual-studio-code-bin netease-cloud-music wps-office-cn ttf-wps-fonts wps-office-mui-zh-cn
dd if=/dev/zero of=/swapfile bs=1M count=4096 status=progress 
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo /swapfile none swap defaults 0 0 >> /etc/fstab
EOF

# Unmount
umount /mnt/boot
umount -R /mnt


# Close the luks container
cryptsetup close cryptroot

reboot

# Enjoy
dd if=/dev/zero of=/swapfile bs=1M count=4096 status=progress 
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo /swapfile none swap defaults 0 0 >> /etc/fstab
EOF

# Unmount
umount /mnt/boot
umount -R /mnt


# Close the luks container
cryptsetup close cryptroot

reboot

# Enjoy