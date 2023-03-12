#!/usr/bin/env bash
#
# Auteur : Valentin Philippot
# Date : Dimanche 05 Mars 2023
# Version 1.0.0 : EasyInstall"
#

############################################################################################################
function language_choice() {
ADVSEL=$(whiptail --title "Language Choice" --fb --menu "Please select the language" 15 60 4 \
  "1" "French" \
  "2" "English" 3>&1 1>&2 2>&3)

  case $ADVSEL in

    1)
        source language/fr_FR.conf > /dev/null 2>&1
        clear
        echo -e "$msg_copyright"
        sleep 2
        menuprincipal
       ;;
    2)
        source language/en_EN.conf > /dev/null 2>&1
        echo "$msg_copyright"
        menuprincipal
       ;; 
   esac
}

############################################################################################################

function menuprincipal() {
 ADVSEL=$(whiptail --title "$mp_title" --fb --menu "$mp_text_option" 15 60 4 \
  "1" "Pterodactyl" \
  "2" "PhpMyAdmin" \
  "3" "PufferPanel" 3>&1 1>&2 2>&3)

  case $ADVSEL in

    1)
        menupterodactyl
       ;;
    2)
        menupma
       ;;
    3)
        menupufferpanel
       ;;
   esac
}
############################################################################################################

function menupma() {
  ADVSEL=$(whiptail --title "$mpma_title" --fb --menu "$mpma_text_option" 15 60 4 \
  "1" "$mpma_choice1" \
  "2" "$mpma_choice2" 3>&1 1>&2 2>&3)

  case $ADVSEL in

    1)
        install_pma
       ;;
    2)
        unistall_pma
       ;;
   esac
}

function install_phpmyadmin(){
    if whiptail --yesno "$inst_question" 10 100 --defaultno; then
      source /etc/os-release
      case $PRETTY_NAME in
        Ubuntu\ 18.*)
          whiptail --infobox "$WHPT_instpma" 20 78
          sleep 2
          source ./install-pma_ubuntu_18.sh
          ;;
        Ubuntu\ 22.*)
          whiptail --infobox "$WHPT_instpma" 20 78
          sleep 2
          source ./install-pma_ubuntu_22.sh
          ;;
        Debian\ *\ 10*)
          whiptail --infobox "$WHPT_instpma" 20 78
          sleep 2
          source ./install-pma_debian_10.sh
          ;;
        Debian\ *\ 11*)
          whiptail --infobox "$WHPT_instpma" 20 78
          sleep 2
          source ./install-pma_debian_11.sh
          ;;
        *)
        echo "$oops_error"
        sleep 5
          ;;
      esac
	      installpma
     else
      menuprincipal
  fi
}
############################################################################################################

function menupterodactyl() {
 ADVSEL=$(whiptail --title "$mpt_title" --fb --menu "$mpt_text_option" 15 75 5 \
  "1" "$mpt_choice1" \
  "2" "$mpt_choice2" \
  "3" "$mpt_choice3" \
  "4" "$mpt_choice4" \
  "5" "$mpt_choice5" \
  "6" "$mpt_choice6" 3>&1 1>&2 2>&3)

  case $ADVSEL in

    1)
        tsb="panel"
        install_ptero
       ;;
    2)
        tsb="wings"  
        install_ptero
       ;;
    3)
        update_panel  
       ;;
    4)
        update_wings  
       ;;
    3)
        unistall_panel  
       ;;
    4)
        unistall_wings  
       ;;
   esac
}
function install_ptero(){
    if whiptail --yesno "$inst_question" 10 100 --defaultno; then
      source /etc/os-release
      case $PRETTY_NAME in
        Ubuntu\ 18.*)
          whiptail --infobox "$WHPT_inst$tsb" 20 78
          sleep 2
          source ./installation-$tsb\_ubuntu_18.sh
          ;;
        Ubuntu\ 22.*)
          whiptail --infobox "$WHPT_inst$tsb" 20 78
          sleep 2
          source ./installation-$tsb\_ubuntu_22.sh
          ;;
        Debian\ *\ 10*)
          whiptail --infobox "$WHPT_inst$tsb" 20 78
          sleep 2
          source ./installation-$tsb\_debian_10.sh
          ;;
        Debian\ *\ 11*)
          whiptail --infobox "$WHPT_inst$tsb" 20 78
          sleep 2
          source ./installation-$tsb\_debian_11.sh
          ;;
        *)
        echo "$oops_error"
        sleep 5
          ;;
      esac
	      installptero
     else
      menuprincipal
  fi
}

############################################################################################################
#Fonction attribué au couleur pour les texte du script
function couleur(){
noir='\e[0;30m'
gris='\e[1;30m'
rougefonce='\e[0;31m'
rose='\e[1;31m'
vertfonce='\e[0;32m'
vertclair='\e[1;32m'
orange='\e[0;33m'
jaune='\e[1;33m'
bleufonce='\e[0;34m'
bleuclair='\e[1;34m'
violetfonce='\e[0;35m'
violetclair='\e[1;35m'
cyanfonce='\e[0;36m'
cyanclair='\e[1;36m'
grisclair='\e[0;37m'
blanc='\e[1;37m'
neutre='\e[0;m'
}
############################################################################################################
apt install whiptail > /dev/null 2>&1
couleur > /dev/null 2>&1
language_choice

############################################################################################################

