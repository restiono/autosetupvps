#!/bin/bash
function print_info {
        echo -n -e '\e[1;36m'
        echo -n $1
        echo -e '\e[0m'
}

wget -nv -O /tmp/phpmyadmin.tar.bz2 http://downloads.sourceforge.net/project/phpmyadmin/phpMyAdmin/4.2.10.1/phpMyAdmin-4.2.10.1-english.tar.bz2

cd /tmp
tar -xjf phpmyadmin.tar.bz2
mv phpMyAdmin-4.2.10.1-english phpmyadmin
rm -rf phpmyadmin.tar.bz2
mv phpmyadmin /var/www/
chown www-data.www-data /var/www/phpmyadmin -R

cat > "/var/www/phpmyadmin/config.inc.php" <<END
<?php
$cfg['blowfish_secret'] = 'a8b7c6d'; 
$i = 0;
$i++;
$cfg['Servers'][$i]['auth_type'] = 'cookie';
$cfg['Servers'][$i]['host'] = 'localhost';
$cfg['Servers'][$i]['connect_type'] = 'socket';
$cfg['Servers'][$i]['socket'] = '/var/run/mysqld/mysqld.sock';
$cfg['Servers'][$i]['compress'] = false;
$cfg['Servers'][$i]['AllowNoPassword'] = false;
$cfg['UploadDir'] = '';
$cfg['SaveDir'] = '';
?>
END

cat > "/etc/nginx/pma_pass" <<END
pengguna:F/2yKIiuw0Ue2
END

cat > "/etc/nginx/sites-available/phpmyadmin.conf" <<END
server {
	listen 81;
	server_name _;
	root /var/www/phpmyadmin;
	index index.php index.html index.htm;
	client_max_body_size 32m;

	access_log  /var/log/nginx/phpmyadmin_access.log;
	error_log  /var/log/nginx/phpmyadmin_error.log;
	
	# Set auth basic for user
	auth_basic "Admin Login";
	auth_basic_user_file /etc/nginx/pma_pass;

	# Directives to send expires headers and turn off 404 error logging.
	location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
		expires max;
		log_not_found off;
		access_log off;
	}
	

	location = /favicon.ico {
		log_not_found off;
		access_log off;
	}

	location = /robots.txt {
		allow all;
		log_not_found off;
		access_log off;
	}

	## Disable viewing .htaccess & .htpassword
	location ~ /\.ht {
		deny  all;
	}

	include /etc/nginx/php.conf;
}
END
ln -s /etc/nginx/sites-available/phpmyadmin.conf /etc/nginx/sites-enabled/phpmyadmin.conf
invoke-rc.d nginx restart
invoke-rc.d php5-fpm restart
print_info "PHPMyAdmin sudah terinstall di /var/www/phpmyadmin. Akses dengan namadomain.com:81 atau IP_ANDA:81 dari browser."
