#!/bin/bash

pacman-mirrors -i -c China -m rank
pacman-mirrors --country China --api --set-branch unstable && sudo pacman  --noconfirm -Syyu
pacman -S  --noconfirm yay 
yay -S  --noconfirm v2raya google-chrome fcitx-qt4 fcitx-qt5 fcitx-configtool xsettingsd visual-studio-code-bin netease-cloud-music wps-office-cn ttf-wps-fonts wps-office-mui-zh-cn wine deepin-wine deepin-wine5 deepin-wine-wechat 
#sed -i "s/export LD_LIBRARY_PATH="${HERE}"/libs/export LD_LIBRARY_PATH=/usr/libs/g" /opt/netease/netease-cloud-music/netease-cloud-music.bash
