function install(){
#Pour wget sur vps en full ipv6 remplacer --inet4-only par --inet6-only
#Pour curl sur vps en full ipv6 remplacer -Lo4 par -Lo6
#!/bin/bash
#!/usr/bin/env perl
sudo locale-gen fr_FR.UTF-8 > /dev/null 2>&1
sudo export LANG=C.UTF-8 > /dev/null 2>&1
sudo update-locale LANG=fr_FR.UTF-8 > /dev/null 2>&1

whiptail --infobox "Attention l'installation pour l'os ubuntu 22 n'est pas encore prête" 20 78
sleep 4
advancedMenu
}
