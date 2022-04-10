#/bin/bash
# Thanks to Heyan Maurya on https://www.how2shout.com/linux/script-to-install-lamp-wordpress-on-ubuntu-20-04-lts-server-quickly-with-one-command/ for providing most of that scipt
clear
echo "Welcome to the installation Script of Wordpress, Nginx and Mysql"
useraccept=false

while ! $useraccept; do 
    install_dir="/var/www/html"
    #Creating Random WP Database Credenitals
    db_name="wp`date +%s`"
    db_user=$db_name
    db_password=`date |md5sum |cut -c '1-12'`
    sleep 1
    mysqlrootpass=`date |md5sum |cut -c '1-12'`
    sleep 1

    echo "--------------------------------------"
    echo "Installation Directory: $install_dir"
    echo "Database Name: $db_name"
    echo "Database User: $db_user"
    echo "Database Password: $db_password"
    echo "MySQL Root Password: $mysqlrootpass"
    echo "--------------------------------------"
    echo "Do you want to change these values? (Y|Yes|y|yes) for yes or sth else for no (Default NO)"
    read useraccvalues

    if  [[ $useraccvalues == "" ]]; then 
        useraccept=true
        break
    fi

    if [ $useraccvalues == "Y" ] || [  $useraccvalues == "Yes" ] ||  [ $useraccvalues == "y" ]  || [ $useraccvalues == "yes" ] 
    then 
        echo "Installation Directory: (Enter for Empty)"
        read Uinstall_dir
        if [[ $Uinstall_dir != "" ]]; then
            install_dir=$Uinstall_dir
            #echo $mysqlrootpass
        fi
        echo "Database Name: (Enter for Empty)"
        read Udb_name
        if [[ $Udb_name != "" ]]; then
            db_name=$Udb_name
            #echo $db_name
        fi
        echo "Database User: (Enter for Empty)"
        read Udb_user
        if [[ $Udb_user != "" ]]; then
            db_user=$Udb_user
            #echo $db_user
        fi
        echo "Database Password: (Enter for Empty)"
        read Udb_password
        if [[ $Udb_password != "" ]]; then
            db_password=$Udb_password
            #echo $db_password
        fi
        echo "Mysql Root User Password: (Enter for Empty)"
        read Umysqlrootpass
        if [[ $Umysqlrootpass != "" ]]; then
            mysqlrootpass=$Umysqlrootpass
            #echo $mysqlrootpass
        fi
         
        #echo $install_dir $db_name $db_user $db_password $mysqlrootpass

        useraccept=true
    fi
    useraccept=true     
done
echo "Finish"

#### Install Packages for https and mysql
apt -y update 
apt -y upgrade
apt -y install nginx
apt -y install mysql-server

#### Start http
rm /var/www/html/index.html
systemctl enable nginx
systemctl start nginx

#### Start mysql and set root password

systemctl enable mysql
systemctl start mysql

/usr/bin/mysql -e "USE mysql;"
/usr/bin/mysql -e "UPDATE user SET Password=PASSWORD($mysqlrootpass) WHERE user='root';"
/usr/bin/mysql -e "FLUSH PRIVILEGES;"
touch /root/.my.cnf
chmod 640 /root/.my.cnf
echo "[client]">>/root/.my.cnf
echo "user=root">>/root/.my.cnf
echo "password="$mysqlrootpass>>/root/.my.cnf
####Install PHP
apt -y install php php-bz2 php-mysqli php-curl php-gd php-intl php-common php-mbstring php-xml

#sed -i '0,/AllowOverride\ None/! {0,/AllowOverride\ None/ s/AllowOverride\ None/AllowOverride\ All/}' /etc/apache2/apache2.conf #Allow htaccess usage

systemctl restart nginx

####Download and extract latest WordPress Package
if test -f /tmp/latest.tar.gz
then
echo "WP is already downloaded."
else
echo "Downloading WordPress"
cd /tmp/ && wget "http://wordpress.org/latest.tar.gz";
fi

/bin/tar -C $mysqlrootpass -zxf /tmp/latest.tar.gz --strip-components=1
chown www-data: $mysqlrootpass -R

#### Create WP-config and set DB credentials
/bin/mv $mysqlrootpass/wp-config-sample.php $mysqlrootpass/wp-config.php

/bin/sed -i "s/database_name_here/$db_name/g" $mysqlrootpass/wp-config.php
/bin/sed -i "s/username_here/$db_user/g" $mysqlrootpass/wp-config.php
/bin/sed -i "s/password_here/$db_password/g" $mysqlrootpass/wp-config.php

cat << EOF >> $mysqlrootpass/wp-config.php
define('FS_METHOD', 'direct');
EOF

cat << EOF >> $mysqlrootpass/.htaccess
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index.php$ – [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
EOF

chown www-data: $mysqlrootpass -R

##### Set WP Salts
grep -A50 'table_prefix' $mysqlrootpass/wp-config.php > /tmp/wp-tmp-config
/bin/sed -i '/**#@/,/$p/d' $mysqlrootpass/wp-config.php
/usr/bin/lynx --dump -width 200 https://api.wordpress.org/secret-key/1.1/salt/ >> $mysqlrootpass/wp-config.php
/bin/cat /tmp/wp-tmp-config >> $mysqlrootpass/wp-config.php && rm /tmp/wp-tmp-config -f
/usr/bin/mysql -u root -e "CREATE DATABASE $db_name"
/usr/bin/mysql -u root -e "CREATE USER '$db_name'@'localhost' IDENTIFIED WITH mysql_native_password BY '$db_password';"
/usr/bin/mysql -u root -e "GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'localhost';"
 
######Display generated passwords to log file.
echo "Database Name: " $db_name
echo "Database User: " $db_user
echo "Database Password: " $db_password
echo "Mysql root password: " $mysqlrootpass
 
