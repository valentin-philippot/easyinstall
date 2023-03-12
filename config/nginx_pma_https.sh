#!/usr/bin/env bash
#
# Auteur : Valentin Philippot
# Date : Dimanche 05 Mars 2023
# Version 1.0.0 : EasyInstall"
#

function nginxpmahttps(){
#[Installation des dépendences tels que Nginx ainsi que certbot et arrêt de Nginx]
apt install -y nginx certbot
systemctl stop nginx
#[Demmande de l'url pour l'accée web et création du certificat ssl avec certbot]
PMA_URL=$(whiptail --inputbox "$WHPT_urlhttps" 20 78 3>&1 1>&2 2>&3)
echo -e "$QP4"
certbot certonly --standalone -d $(echo $PMA_URL | awk -F'//' '{print $2}' | awk -F'/' '{print $1}')
#[Ecris de la configuration dans sont fichier pour le fonctionnement de Nginx]
cat << OEF > /etc/nginx/sites-available/phpmyadmin.conf
server {
    listen 80;
    server_name $(echo $PMA_URL | awk -F'//' '{print $2}' | awk -F'/' '{print $1}');
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $(echo $PMA_URL | awk -F'//' '{print $2}' | awk -F'/' '{print $1}'); 
   
    root /usr/share/phpmyadmin;
    index index.php;
    client_max_body_size 100m;
    client_body_timeout 120s;

    sendfile off;

    access_log /var/log/nginx/phpmyadmin.app-access.log;
    error_log  /var/log/nginx/phpmyadmin.app-error.log error;

    ssl_certificate /etc/letsencrypt/live/$(echo $APP_URL | awk -F'//' '{print $2}' | awk -F'/' '{print $1}')/fullchain.pem; 
    ssl_certificate_key /etc/letsencrypt/live/$(echo $APP_URL | awk -F'//' '{print $2}' | awk -F'/' '{print $1}')/privkey.pem; 
    ssl_session_cache shared:SSL:10m;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";
    ssl_prefer_server_ciphers on;
	
	
    # See https://hstspreload.org/ before uncommenting the line below.
    # add_header Strict-Transport-Security "max-age=15768000; preload;";
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Robots-Tag none;
    add_header Content-Security-Policy "frame-ancestors 'self'";
    add_header X-Frame-Options DENY;
    add_header Referrer-Policy same-origin;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param HTTP_PROXY "";
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
        include /etc/nginx/fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
OEF
#[Création d'un lien symbolique entre le dossier sites-available et sites-enabled pour le fichier phpmyadmin.conf]
sudo ln -s /etc/nginx/sites-available/phpmyadmin.conf /etc/nginx/sites-enabled/phpmyadmin.conf
#[Suppression des fichier inutile de PhpMyAdmin]
rm -rf /usr/share/phpmyadmin/config
rm -rf /usr/share/phpmyadmin/setup
#[Activation au boot et Démarrage de Nginx + Affichage des stats de Apache2]
systemctl enable --now nginx
systemctl status nginx
}