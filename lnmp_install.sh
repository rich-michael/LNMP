#/bin/bash
#配置yum源
cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak 
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo 
wget -P /etc/yum.repos.d/ http://mirrors.aliyun.com/repo/epel-7.repo

#环境安装
yum install ncurses-devel libxml2 libxml2-devel openssl openssl-devel bzip2 bzip2-devel libcurl libcurl-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel gmp gmp-devel libmcrypt libmcrypt-devel readline readline-devel libxslt libxslt-devel 


#包解压并准备
mkdir /soft
cd /soft
yum -y install git 
git clone https://github.com/rich-michael/LNMP.git

cd LNMP
#1-nignx安装 
yum -y install nginx
cp -rf nginx.conf /etc/nginx/nginx.conf
cp -rf open.szprize.conf /etc/nginx/conf.d/
systemctl start nginx.service
systemctl enalbe nginx.service

#2-安装mysql
#rpm -ivh mysql-community-release-el7-5.noarch.rpm
#yum install mysql-community-server

#3-安装PHP
tar -xf php-7.1.10.tar.gz  -C /soft
cd /soft/php-7.1.10
cd php-7.1.10

./configure \
--prefix=/usr/local/php \
--with-config-file-path=/etc \
--enable-fpm \
--with-fpm-user=nginx \
--with-fpm-group=nginx \
--enable-inline-optimization \
--disable-debug \
--disable-rpath \
--enable-shared \
--enable-soap \
--with-libxml-dir \
--with-xmlrpc \
--with-openssl \
--with-mcrypt \
--with-mhash \
--with-pcre-regex \
--with-sqlite3 \
--with-zlib \
--enable-bcmath \
--with-iconv \
--with-bz2 \
--enable-calendar \
--with-curl \
--with-cdb \
--enable-dom \
--enable-exif \
--enable-fileinfo \
--enable-filter \
--with-pcre-dir \
--enable-ftp \
--with-gd \
--with-openssl-dir \
--with-jpeg-dir \
--with-png-dir \
--with-zlib-dir \
--with-freetype-dir \
--enable-gd-native-ttf \
--enable-gd-jis-conv \
--with-gettext \
--with-gmp \
--with-mhash \
--enable-json \
--enable-mbstring \
--enable-mbregex \
--enable-mbregex-backtrack \
--with-libmbfl \
--with-onig \
--enable-pdo \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--with-zlib-dir \
--with-pdo-sqlite \
--with-readline \
--enable-session \
--enable-shmop \
--enable-simplexml \
--enable-sockets \
--enable-sysvmsg \
--enable-sysvsem \
--enable-sysvshm \
--enable-wddx \
--with-libxml-dir \
--with-xsl \
--enable-zip \
--enable-mysqlnd-compression-support \
--with-pear \
--enable-opcache

[$? -eq 0 ]&&make&&make install 
#编译完进行配置
cd /soft/LNMP/
touch /var/run/php7-fpm.sock
chmod 777 /var/run/php7-fpm.sock
cp -rf /soft/LNMP/php.ini /etc/php.ini 
cp -rf /soft/LNMP/php-fpm.service  /lib/systemd/system/
cp -rf /soft/LNMP/php-fpm.conf /usr/local/php/etc/php-fpm.conf
cp -rf /soft/LNMP/www.conf /usr/local/php/etc/php-fpm.d/
echo 'PATH=$PATH:/usr/local/php/bin/' >> /etc/profile
echo "export PATH" >> /etc/profile
source /etc/profile

#4-安装PHP拓展
tar zxvf libmemcached-1.0.18.tar.gz  -C /usr/local/
cd /usr/local/libmemcached-1.0.18 
phpize 
./configure 
make 
make install
cd /soft/LNMP

#5-安装memcache拓展
cd php-memcached 
phpize 
./configure –disable-memcached-sasl 
make 
make install
cd ..

#6安装redis拓展
cd phpredis
phpize
./configure [--enable-redis-igbinary]
make && make install
cd ..

#php启动
systemctl daemon-reload
systemctl start php-fpm.service 


