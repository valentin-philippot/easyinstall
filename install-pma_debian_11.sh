#!/usr/bin/env bash
#
# Auteur : Valentin Philippot
# Date : Dimanche 05 Mars 2023
# Version 1.0.0 : EasyInstall"
#

function installpma(){
echo -e "$QP1" # -> = /language/lang_LANG.conf
apt update && apt full-upgrade -y --autoremove --purge
apt install -y wget curl zip sudo php8.2-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip,json}
phpenmod mbstring
echo -e "$QP2" # -> = /language/lang_LANG.conf
cd /usr/share && wget --inet4-only https://files.phpmyadmin.net/phpMyAdmin/5.2.0/phpMyAdmin-5.2.0-all-languages.zip && unzip phpMyAdmin-5.2.0-all-languages.zip
mv phpMyAdmin-5.2.0-all-languages phpmyadmin
rm phpMyAdmin*zip && cd phpmyadmin
cp config.sample.inc.php config.inc.
echo -e "$QP3" # -> = /language/lang_LANG.conf
if (whiptail --title "$WHPT_title_apache2_nginx" --yesno "$WHPT_qst_nginx_apache2" 8 78 --no-button "APACHE2" --yes-button "NGINX"); then
    
    #CONFIG NGINX
    if (whiptail --title "$WHPT_title_LOC_EXT" --yesno "$WHPT_qst_loc_dmext" 8 78 --no-button "LOCALHOST" --yes-button "DOMAINE-EXTERNE"); then
    source ./config/nginx_pma_https.sh > /dev/null 2>&1
    nginxpmahttps
    else
    source ./config/nginx_pma_http.sh > /dev/null 2>&1
    nginxpmahttp
    fi
else
    #CONFIG APACHE2
    if (whiptail --title "$WHPT_title_LOC_EXT" --yesno "$WHPT_qst_loc_dmext" 8 78 --no-button "LOCALHOST" --yes-button "DOMAINE-EXTERNE"); then
    source ./config/apache2_pma_https.sh > /dev/null 2>&1
    apache2pmahttps
    else
    source ./config/apache2_pma_http.sh > /dev/null 2>&1
    apache2pmahttp
    fi
fi  
    sleep 0.5
    whiptail --infobox "$WHPT_finishinstpma" 20 78
    menuprincipal
}