#!/usr/bin/env bash
#
# Auteur : Valentin Philippot
# Date : Dimanche 05 Mars 2023
# Version 1.0.0 : EasyInstall"
#
function nginxpterohttps() {
#[Suppression des configuration precedente presente dans nginx]
rm -r /etc/nginx/sites-enabled/default
rm -r /etc/nginx/sites-enabled/pterodactyl.conf
#[Ecris du fichier de configuration pterodactyl.conf pour le fonctionnement de nginx]
source /var/www/pterodactyl/.env
cat << OEF > /etc/nginx/sites-available/pterodactyl.conf
server_tokens off;

server {
    listen 80;
    server_name $(echo $APP_URL | awk -F'//' '{print $2}' | awk -F'/' '{print $1}');
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $(echo $APP_URL | awk -F'//' '{print $2}' | awk -F'/' '{print $1}');

    root /var/www/pterodactyl/public;
    index index.php;

    access_log /var/log/nginx/pterodactyl.app-access.log;
    error_log  /var/log/nginx/pterodactyl.app-error.log error;

    # allow larger file uploads and longer script runtimes
    client_max_body_size 100m;
    client_body_timeout 120s;

    sendfile off;

    # SSL Configuration - Replace the example <domain> with your domain
    ssl_certificate /etc/letsencrypt/live/$(echo $APP_URL | awk -F'//' '{print $2}' | awk -F'/' '{print $1}')/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$(echo $APP_URL | awk -F'//' '{print $2}' | awk -F'/' '{print $1}')/privkey.pem;
    ssl_session_cache shared:SSL:10m;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384";
    ssl_prefer_server_ciphers on;

    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Robots-Tag none;
    add_header Content-Security-Policy "frame-ancestors 'self' ";
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
        fastcgi_param PHP_VALUE "upload_max_filesize = 500M post_max_size=500M";
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
#[Creation d'un lien symbolique entre le dossier sites-available et sites-enabled pour pterodactyl.conf]
sudo ln -s /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf
#Création du certificat SSL pour l'https sur le domaine/sous-domaine 
echo -e "Création du certificat SSL pour l'https sur $APP_URL"
certbot certonly --standalone -d $(echo $APP_URL | awk -F'//' '{print $2}' | awk -F'/' '{print $1}')
#Activation au boot et demarrage de nginx]
systemctl enable --now nginx
}