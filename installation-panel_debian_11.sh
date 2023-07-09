#!/usr/bin/env bash
#
# Auteur : Valentin Philippot
# Date : Dimanche 05 Mars 2023
# Version 1.0.0 : Install the Pterodactyl Panel!"
#

function installptero(){
#[Update du serveur et Ajouts/Installation des Dépendences]
sudo echo "$Q1" # -> = /language/lang_LANG.conf
sleep 0.5
sudo apt-get update && apt-get full-upgrade -y --autoremove --purge
sudo apt-get install -y curl wget perl sudo certbot htop pwgen gnupg{,2} software-properties-common apt-transport-https ca-certificates tar unzip git redis-server
sudo curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash 
sudo curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg
sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
sudo apt-get update && apt-get install -y php8.2-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip} mariadb-server nginx lsb-release
sudo curl -Ss https://getcomposer.org/installer | php 
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

#[Telechargement et Creation des dossies Panel]
sudo echo -e "$Q2" # -> = /language/lang_LANG.conf
sleep 0.5
sudo mkdir -p /var/www/pterodactyl
sudo cd /var/www/pterodactyl || exit
sudo curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
sudo tar -xzvf panel.tar.gz
sudo chmod -R 755 storage/* bootstrap/cache/

#[Creation de la db et du user pour le Panel]
sudo echo -e "$Q3" # -> = /language/lang_LANG.conf
sleep 0.5
userdbptero=$(whiptail --inputbox "Utilisateur [Pterodactyl]:" 20 78 3>&1 1>&2 2>&3)
userdbptero=${userdbptero//[^a-zA-Z0-9_]/}
if [ -z "$userdbptero" ]; then 
userdbptero="pterodactyl" 
fi
mdpdbptero=$(whiptail --inputbox "Mot de Passe [VotreMotPass]:" 20 78 3>&1 1>&2 2>&3)
mdpdbptero=${mdpdbptero//[^a-zA-Z0-9_@!]/}
if [ -z "$mdpdbptero" ]; then
mdpdbptero=$(pwgen -sy -r\'\"\` 32 1)
fi
whiptail --msgbox --title "$WHPT_title_warninginfsql" "$infsql" 20 78
sudo mysql --execute "CREATE USER '$userdbptero'@'127.0.0.1' IDENTIFIED BY '$mdpdbptero';"
sudo mysql --execute "CREATE DATABASE panel;"
sudo mysql --execute "GRANT ALL PRIVILEGES ON panel.* TO '$userdbptero'@'127.0.0.1' WITH GRANT OPTION;"
sudo mysql --execute "exit"

#[Configuration des élement nécessaire au fonctionnement du panel]
sudo echo -e "$Q4" # -> = /language/lang_LANG.conf
sleep 0.5
sudo cd /var/www/pterodactyl || exit
sudo cp .env.example .env
sudo composer install --no-dev --optimize-autoloader
sudo php artisan key:generate --force
sudo php artisan p:environment:setup #-> Configuration du Sous-domaine et autre
sudo php artisan p:environment:database #-> Configuration Database 'Avec identifiant précedemment crée a la ligne 62'
sudo php artisan migrate --seed --force
sudo systemctl stop nginx
sudo php artisan p:environment:mail
sudo php artisan p:user:make #-> Création du user Administrateur
sudo chown -R www-data:www-data /var/www/pterodactyl/*

#Congiration du crontab
sudo echo -e "$Q5" # -> = /language/lang_LANG.conf
sleep 0.5
##crontab -e www-data:www-data

#Copier la ligne suivante dans le fichier une fois le crontab ouvert pensser a faire CTRL+O pour sauvegarder
##* * * * * php /var/www/pterodactyl/artisan schedule:run >> /dev/null 2>&1 

#Création du fichier de démarrage automatique au boot du service Pteroq
sudo echo -e "$Q6" # -> = /language/lang_LANG.conf
sleep 0.5
sudo cat << OEF > /etc/systemd/system/pteroq.service
# Pterodactyl Queue Worker File
# ----------------------------------

[Unit]
Description=Pterodactyl Queue Worker
After=redis-server.service

[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/pterodactyl/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target
OEF

#Affichage du status du service pteroq pour visualiser en cas de debug
sudo echo "$Q7" # -> = /language/lang_LANG.conf
sleep 0.5
sudo systemctl enable --now pteroq.service
sleep 1
sudo systemctl stop nginx

#Configuration du reverse proxy pour le panel Pterodactyl
sudo echo "$Q8" # -> = /language/lang_LANG.conf
sleep 0.5
sudo cd /root/superinstall-main/ || exit 
if (whiptail --title "$WHPT_title_httphttps" --yesno "$WHPT_qst_locdmext" 8 78 --no-button "LOCALHOST" --yes-button "DOMAINE-EXTERNE"); then
sudo source ./config/nginx_https.sh > /dev/null 2>&1
nginxpterohttps
else
sudo source ./config/nginx_http.sh > /dev/null 2>&1
nginxpterohttp
fi

#Fin de l'installation, Affichage des status des services en cas de Debug
sudo echo -e "$Q9" # -> = /language/lang_LANG.conf
sudo echo -e "$Q10" # -> = /language/lang_LANG.conf
sleep 0.5
sudo systemctl status nginx
sleep 0.5
sudo systemctl status pteroq.service
sleep 0.5
whiptail --infobox "$WHPT_finish_install_panel" 20 78
sleep 4
menuprincipal
}
