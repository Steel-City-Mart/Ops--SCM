#! /bin/bash

sudo su
apt-get update
apt-get upgrade
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile swap swap defaults 0 0">> /etc/fstab
apt install nginx
apt install ufw
ufw allow 'Nginx HTTP'
apt install mysql-server
mysql_secure_installation
apt install php-fpm php-mysql
mkdir /var/www/php_sites
vi /etc/nginx/sites-available/php_sites.conf
********* Add this to the above file thorugh vi
server {
    listen 80;
    listen [::]:80;

    root /var/www/php_sites;
    index index.php index.html index.htm;

    server_name php_sites;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
    }
}
*********
ln -s /etc/nginx/sites-available/php_sites.conf /etc/nginx/sites-enabled/
nginx -t ##to check if the config has any errors
systemctl reload nginx
apt install phpmyadmin
ln -s /usr/share/phpmyadmin /var/www/php_sites/phpmyadmin
ufw allow http
ufw allow https
ufw allow tcp
ufw allow udp
mariadb -u root -p
CREATE USER 'dbuser'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'dbuser'@'%' WITH GRANT OPTION;
exit
ufw allow 3306/tcp
vi /etc/mysql/mariadb.conf.d/50-server.cnf
********* edit
user=dbuser
...
bind-address = 0.0.0.0
*********

# after this activity, edit the firewall rules for the GCP project, and add rules for ingress/egress
# from all ips to port 3306 of the instance. post this mariadb must be accessible outside the vm