FROM php:7.4-apache

WORKDIR /var/www

ENV APACHE_DOCUMENT_ROOT=/var/www/html

RUN sed -i '/<Directory ${APACHE_DOCUMENT_ROOT}>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
RUN a2enmod rewrite

RUN apt-get update && apt-get install -y \
        git cron nano libzip-dev unzip libldap2-dev libpq-dev  \
    && docker-php-ext-configure zip \
    && docker-php-ext-install mysqli pdo pdo_mysql pgsql pdo_pgsql zip ldap

ADD crontab /etc/cron.d/my-cron-file
RUN chmod 0644 /etc/cron.d/my-cron-file
RUN crontab /etc/cron.d/my-cron-file

ADD entrypoints/00_cron /opt/run/
ADD entrypoints/01_apache /opt/run/
RUN chmod +x /opt/run/*

ADD entrypoints/run_all /opt/bin/
RUN chmod +x /opt/bin/run_all
ENTRYPOINT ["/opt/bin/run_all"]

#ENTRYPOINT ["cron", "-f"]