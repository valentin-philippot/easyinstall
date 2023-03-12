#!/bin/bash
function nginxpterohttp (){
#[Suppression des configuration precedente presente dans nginx]
rm -r /etc/nginx/sites-enabled/default
rm -r /etc/nginx/sites-enabled/pterodactyl.conf
#[Ecris du fichier de configuration pterodactyl.conf pour le fonctionnement de nginx]
source /var/www/pterodactyl/.env
cat << OEF > /etc/nginx/sites-available/pterodactyl.conf
server {
    listen 80;
    server_name $(echo $APP_URL | awk -F'//' '{print $2}' | awk -F'/' '{print $1}');


    root /var/www/pterodactyl/public;
    index index.html index.htm index.php;
    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/pterodactyl.app-error.log error;

    # allow larger file uploads and longer script runtimes
    client_max_body_size 100m;
    client_body_timeout 120s;

    sendfile off;

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
    }

    location ~ /\.ht {
        deny all;
    }
}
OEF
#[Creation d'un lien symbolique entre le dossier sites-available et sites-enabled pour pterodactyl.conf]
sudo ln -s /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf
#Activation au boot et demarrage de nginx]
systemctl enable --now nginx
}