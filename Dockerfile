# Node Builder
FROM node:14.7.0-alpine as node-builder
COPY ./ /home/www/project
WORKDIR /home/www/project
RUN rm package-lock.json && yarn && npm run production && rm -fr node_modules

# PHP Builder
FROM php:7.3-apache-stretch
COPY --from=node-builder /home/www/project /var/www/app
COPY default.conf /etc/apache2/sites-enabled/000-default.conf
WORKDIR /var/www/app
RUN apt-get update -yqq && \
  apt-get install -y apt-utils zip unzip && \
  apt-get install -y nano && \
  apt-get install -y libzip-dev && \
  a2enmod rewrite && \
  docker-php-ext-install mysqli pdo pdo_mysql && \
  docker-php-ext-configure zip --with-libzip && \
  docker-php-ext-install zip && \
  rm -rf /var/lib/apt/lists/* && \
  cp .env.example .env && \ 
  php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer && \
  composer install --ignore-platform-reqs && \
  chmod -R 777 vendor storage && \
  php artisan key:generate
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
EXPOSE 80
