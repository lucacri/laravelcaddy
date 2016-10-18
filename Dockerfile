FROM phusion/baseimage:latest

MAINTAINER "Luca Critelli" <lucacri@gmail.com>

RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get update && \
apt-get install -y software-properties-common && \
LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php && \
apt-get update && \
apt-get upgrade -y && \
BUILD_PACKAGES="python3 php7.0-fpm php7.0-zip php7.0-bz2 php7.0-mysql php-memcached php7.0-mysql php7.0-curl php7.0-gd php7.0-intl php7.0-mcrypt php7.0-sqlite3 php7.0-tidy php7.0-pgsql php7.0-xml nano php-mbstring" && \
apt-get -y install $BUILD_PACKAGES && \
apt-get remove --purge -y software-properties-common && \
apt-get autoremove -y && \
apt-get clean && \
apt-get autoclean && \
echo -n > /var/lib/apt/extended_states && \
rm -rf /var/lib/apt/lists/* && \
rm -rf /usr/share/man/?? && \
rm -rf /usr/share/man/??_* && \
find /etc/php/7.0/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \; && \
rm /etc/php/7.0/cli/conf.d/20-mcrypt.ini && rm /etc/php/7.0/fpm/conf.d/20-mcrypt.ini && \
phpenmod mcrypt && mkdir /run/php && chmod 777 /run/php && \
sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.0/fpm/php.ini && \
sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php/7.0/fpm/php.ini && \
sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php/7.0/fpm/php.ini && \
sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.0/fpm/php-fpm.conf && \
mkdir -p /var/www && \
usermod -u 1000 www-data && \
usermod -a -G users www-data && \
chown -R www-data:www-data /var/www/ && \
mkdir -p /etc/service/caddy && \
mkdir -p /etc/service/phpfpm && \
mkdir /etc/service/logs && \
mkdir -p /etc/my_init.d && \
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
php -r "if (hash_file('SHA384', 'composer-setup.php') === 'e115a8dc7871f15d853148a7fbac7da27d6c0030b848d9b3dc09e2a0388afed865e6a3d6b3c0fad45c48e2b5fc1196ae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
php -r "unlink('composer-setup.php');"



COPY ./fpmpool.conf /etc/php/7.0/fpm/pool.d/www.conf
COPY ./caddy-0.9 /bin/caddy
ADD logrotate_laravel.conf /etc/logrotate.d/laravel
COPY ./caddy.conf /caddy.conf

ADD ./caddy.sh /etc/service/caddy/run
ADD ./phpfpm.sh /etc/service/phpfpm/run
ADD ./boot.sh /etc/my_init.d/boot.sh
ADD ./logs.sh /etc/service/logs/run

RUN chmod +x /etc/service/caddy/run && chmod +x /etc/service/phpfpm/run && chmod +x /etc/my_init.d/boot.sh && chmod 777 /etc/service/logs/run


ENV APP_ENV=local \
    APP_DEBUG=true \
    DB_HOST=db \
    DB_DATABASE=laravel \
    DB_USERNAME=laravel \
    DB_PASSWORD=laravelpass \
    APP_URL="http://laravel.dev" \
    APP_KEY="kD7qEXQBJUmURfVHvsHyWTVG9UmkZoUR" \
    DB_TYPE=pgsql \
    DB_PORT=5432 \
    QUEUE_DRIVER=beanstalkd \
    QUEUE_HOST=queue \
    CACHE_DRIVER=redis \
    REDIS_HOST=redis \
    SESSION_DRIVER=redis \
    APP_FILESYSTEM=local  \
    MAIL_PRETEND=true


CMD ["/sbin/my_init"]
EXPOSE 80