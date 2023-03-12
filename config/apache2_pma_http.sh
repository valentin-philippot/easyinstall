#!/usr/bin/env bash
#
# Auteur : Valentin Philippot
# Date : Dimanche 05 Mars 2023
# Version 1.0.0 : EasyInstall"
#

function apache2pmahttp (){
#[Installation de la dépendence Apache2 et arrêt de Apache2]
apt install -y apache2
systemctl stop apache2
#[Demmande de l'ip de la machine]
PMA_IP=$(whiptail --inputbox "$WHPT_iphttp" 20 78 3>&1 1>&2 2>&3)
#[Ecris de la configuration dans sont fichier pour le fonctionnement de Apache2]
cat << OEF > /etc/apache2/sites-available/phpmyadmin.conf
<VirtualHost *:80>
  ServerName $(echo $PMA_URL | awk -F'//' '{print $2}' | awk -F'/' '{print $1}')
  DocumentRoot "/usr/share/phpmyadmin"
  AllowEncodedSlashes On
  php_value upload_max_filesize 100M
  php_value post_max_size 100M
  <Directory "/usr/share/phpmyadmin">
    AllowOverride all
  </Directory>
</VirtualHost>
OEF
#[Activation du fichier de configuration prècedemment ecris et activation du mod rewrite]
a2ensite phpmyadmin.conf
a2enmod rewrite
#[Suppression des fichier inutile de PhpMyAdmin]
rm -rf /usr/share/phpmyadmin/config
rm -rf /usr/share/phpmyadmin/setup
#[Activation au boot et Démarrage de Apapche2 + Affichage des stats de Apache2]
systemctl enable --now apache2
systemctl status apache2
}
