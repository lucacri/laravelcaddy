#!/bin/bash
printenv > /var/www/.env
version=$(head -n 1 /var/www/version.txt)
echo "APP_VERSION=$version" >> /var/www/.env

php /var/www/artisan config:clear > /dev/null 2>&1 || true
php /var/www/artisan migrate --force > /dev/null 2>&1 || true
touch /var/www/storage/logs/laravel.log
chown -R www-data:www-data /var/www/storage > /dev/null 2>&1 || true
php /var/www/artisan config:cache > /dev/null 2>&1 || true
php /var/www/artisan route:cache > /dev/null 2>&1 || true
php /var/www/artisan optimize --force > /dev/null 2>&1 || true
