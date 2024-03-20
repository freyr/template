#syntax=docker/dockerfile:1.4
FROM php:8.3.4-fpm-alpine3.19 as os
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN set -eux; \
    apk --no-cache add  \
      unzip  \
    && rm -rf /var/cache/apk/* \
    && install-php-extensions \
      pdo_mysql \
      zip \
    && rm -rf /tmp/*
ENV COMPOSER_ALLOW_SUPERUSER=1
COPY --from=composer/composer:2-bin /composer /usr/bin/composer

FROM os as vendor-production
WORKDIR /build
COPY --link composer.* symfony.* ./
RUN set -eux; \
    composer install --no-cache --prefer-dist --no-dev --no-autoloader --no-scripts --no-progress

FROM os as vendor-development
WORKDIR /build
COPY --link composer.* symfony.* ./
RUN set -eux; \
    composer install --no-cache --prefer-dist --no-autoloader --no-scripts --no-progress

FROM os as runtime-local
ENV COMPOSER_HOME=/.composer
RUN set -eux; \
    apk --no-cache add  \
    bash \
    procps \
    && rm -rf /var/cache/apk/*
RUN set -eux; \
    cp $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini
COPY --link .image/development/php/php-override.ini $PHP_INI_DIR/conf.d/php-override.ini
COPY --link .image/development/php/php-fpm.conf /usr/local/etc/php-fpm.d/php-fpm.conf
RUN set -eux;  \
    install-php-extensions \
    xdebug-3.3.1
USER www-data
WORKDIR /app

FROM runtime-local as runtime-development
COPY --chown=www-data:www-data --from=vendor-development /build/vendor /app/vendor
COPY --chown=www-data:www-data --link public /app/public
COPY --chown=www-data:www-data --link src/ /app/src
COPY --chown=www-data:www-data --link bin/ /app/bin
COPY --chown=www-data:www-data --link tests/ /app/tests
COPY --chown=www-data:www-data --link composer.* ./
RUN set -eux; \
    composer dump-autoload

FROM os as runtime-production
COPY --link .image/production/php/php-override.ini $PHP_INI_DIR/conf.d/php-override.ini
COPY .image/production/php/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf
USER www-data
WORKDIR /app
COPY --chown=www-data:www-data --from=vendor-production /build/vendor /app/vendor
COPY --chown=www-data:www-data --link public /app/public
COPY --chown=www-data:www-data --link src/ /app/src
COPY --chown=www-data:www-data --link bin/ /app/bin
COPY --chown=www-data:www-data --link composer.* ./
RUN set -eux; \
    composer dump-autoload -o --apcu --no-scripts
