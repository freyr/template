#WEB
FROM nginx:1.23.1 as web-local
COPY .image/nginx-development.conf /etc/nginx.conf
EXPOSE 8080

FROM web-local as web-qa
COPY --chown=nginx:nginx public /app/public

FROM web-local as web-production
COPY .image/nginx-production.conf /etc/nginx.conf
COPY --chown=nginx:nginx public /app/public

#PHP
FROM php:8.1.10-fpm-alpine3.16 as os
RUN apk add --virtual .build-deps $PHPIZE_DEPS \
    && apk add \
    bash \
    vim \
    && apk del .build-deps $PHPIZE_DEPS \
    && docker-php-source delete
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
EXPOSE 9000
WORKDIR /app
HEALTHCHECK --interval=10s --timeout=3s --retries=3 CMD ["php-fpm-healthcheck"]
COPY .image/common/php/docker-healthcheck /usr/local/bin/php-fpm-healthcheck
COPY .image/common/php/healthcheck.conf /usr/local/etc/php-fpm.d/healthcheck.conf
COPY .image/common/php/php.ini $PHP_INI_DIR/php.ini

