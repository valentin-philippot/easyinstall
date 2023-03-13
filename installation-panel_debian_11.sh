#!/usr/bin/env bash
#
# Auteur : Valentin Philippot
# Date : Dimanche 05 Mars 2023
# Version 1.0.0 : Install the Pterodactyl Panel!"
#

function ptero(){
#[Update du serveur et Ajouts/Installation des Dépendences]
echo "$Q1" # -> = /language/lang_LANG.conf
sleep 0.5
apt-get update && apt-get full-upgrade -y --autoremove --purge
apt-get install -y curl wget perl sudo certbot htop pwgen gnupg{,2} software-properties-common apt-transport-https ca-certificates tar unzip git redis-server
curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | sudo bash 
curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg
sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
apt-get update && apt-get install -y php8.2-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip} mariadb-server nginx lsb-release
curl -Ss https://getcomposer.org/installer | php 
sudo mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer

#[Telechargement et Creation des dossies Panel]
echo -e "$Q2" # -> = /language/lang_LANG.conf
sleep 0.5
mkdir -p /var/www/pterodactyl
cd /var/www/pterodactyl || exit
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
tar -xzvf panel.tar.gz
chmod -R 755 storage/* bootstrap/cache/

#[Creation de la db et du user pour le Panel]
echo -e "$Q3" # -> = /language/lang_LANG.conf
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
mysql --execute "CREATE USER '$userdbptero'@'127.0.0.1' IDENTIFIED BY '$mdpdbptero';"
mysql --execute "CREATE DATABASE panel;"
mysql --execute "GRANT ALL PRIVILEGES ON panel.* TO '$userdbptero'@'127.0.0.1' WITH GRANT OPTION;"
mysql --execute "exit"

#[Configuration des élement nécessaire au fonctionnement du panel]
echo -e "$Q4" # -> = /language/lang_LANG.conf
sleep 0.5
cd /var/www/pterodactyl || exit
cp .env.example .env
composer install --no-dev --optimize-autoloader
php artisan key:generate --force
php artisan p:environment:setup #-> Configuration du Sous-domaine et autre
php artisan p:environment:database #-> Configuration Database 'Avec identifiant précedemment crée a la ligne 62'
php artisan migrate --seed --force
systemctl stop nginx
php artisan p:environment:mail
php artisan p:user:make #-> Création du user Administrateur
chown -R www-data:www-data /var/www/pterodactyl/*

#Congiration du crontab
echo -e "$Q5" # -> = /language/lang_LANG.conf
sleep 0.5
##crontab -e www-data:www-data

#Copier la ligne suivante dans le fichier une fois le crontab ouvert pensser a faire CTRL+O pour sauvegarder
##* * * * * php /var/www/pterodactyl/artisan schedule:run >> /dev/null 2>&1 

#Création du fichier de démarrage automatique au boot du service Pteroq
echo -e "$Q6" # -> = /language/lang_LANG.conf
sleep 0.5
printf "
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
WantedBy=multi-user.target" $SHELL >> /etc/systemd/system/pteroq.service

#Affichage du status du service pteroq pour visualiser en cas de debug
echo "$Q7" # -> = /language/lang_LANG.conf
sleep 0.5
systemctl enable --now pteroq.service
sleep 1
systemctl stop nginx

#Configuration du reverse proxy pour le panel Pterodactyl
echo "$Q8" # -> = /language/lang_LANG.conf
sleep 0.5
cd /root/superinstall-main/ || exit 
if (whiptail --title "$WHPT_title_httphttps" --yesno "$WHPT_qst_locdmext" 8 78 --no-button "LOCALHOST" --yes-button "DOMAINE-EXTERNE"); then
source ./config/nginx_https.sh > /dev/null 2>&1
nginxpterohttps
else
source ./config/nginx_http.sh > /dev/null 2>&1
nginxpterohttp
fi

#Fin de l'installation, Affichage des status des services en cas de Debug
echo -e "$Q9" # -> = /language/lang_LANG.conf
echo -e "$Q10" # -> = /language/lang_LANG.conf
sleep 0.5
systemctl status nginx
sleep 0.5
systemctl status pteroq.service
sleep 0.5
whiptail --infobox "$WHPT_finish_install_panel" 20 78
sleep 4
menuprincipal
}
