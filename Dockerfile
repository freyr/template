# WEB
FROM nginx:1.23.1 as web-local
EXPOSE 80
COPY .image/development/nginx/ /etc/nginx/

FROM web-local as web-development
COPY --chown=nginx:nginx public /app/public

FROM web-development as web-production
COPY .image/production/nginx/ /etc/nginx/


# APP
FROM php:8.1.10-fpm-alpine3.16 as os
RUN apk add --virtual .build-deps $PHPIZE_DEPS \
    && apk add \
    bash \
    vim \
    && apk del .build-deps $PHPIZE_DEPS \
    && docker-php-source delete \
ENV COMPOSER_HOME /.composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
HEALTHCHECK --interval=10s --timeout=3s --retries=3 CMD ["php-fpm-healthcheck"]
COPY .image/common/php/docker-healthcheck /usr/local/bin/php-fpm-healthcheck
COPY .image/common/php/healthcheck.conf /usr/local/etc/php-fpm.d/healthcheck.conf
COPY .image/common/php/php.ini $PHP_INI_DIR/php.ini
WORKDIR /app
EXPOSE 9000

FROM os as vendor-production
WORKDIR /build
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-interaction --prefer-dist --no-autoloader

FROM os as vendor-development
WORKDIR /build
COPY composer.json composer.lock ./
RUN composer install --no-interaction --prefer-dist --no-autoloader

FROM os as app-local
RUN apk add --virtual .build-deps $PHPIZE_DEPS \
    && pecl install \
    xdebug-3.1.5 \
    && docker-php-ext-enable xdebug \
    && apk del .build-deps $PHPIZE_DEPS \
    && docker-php-source delete
COPY .image/development/php/*.ini $PHP_INI_DIR/conf.d/
COPY .image/development/php/php-fpm.conf /usr/local/etc/php-fpm.d/php-fpm.conf

FROM app-local as app-development
COPY --chown=www-data:www-data . .
COPY --chown=www-data:www-data --from=vendor-development /build/vendor /app/vendor
USER www-data
RUN composer dump-autoload -o --apcu --no-scripts

FROM app-common as app-production
COPY .image/production/php/*.ini $PHP_INI_DIR/conf.d/
COPY .image/production/php/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf
COPY --chown=www-data:www-data . .
COPY --chown=www-data:www-data --from=vendor-production /build/vendor /app/vendor
USER www-data
RUN composer dump-autoload -o --apcu --no-scripts
