ARG PHP_IMAGE=php
ARG PHP_IMAGE_TAG=8.4.13-cli-alpine3.21

FROM ${PHP_IMAGE}:${PHP_IMAGE_TAG} AS base
ARG LOCAL_BIN_PATH=/usr/local/bin
ENV LOCAL_BIN_PATH="${LOCAL_BIN_PATH}"
RUN apk update
RUN apk add --no-cache gcc autoconf icu-dev yaml-dev linux-headers libsodium-dev
RUN apk add --no-cache --virtual .phpize-deps ${PHPIZE_DEPS}
RUN pecl install -o -f ds pcntl posix yaml
RUN docker-php-ext-configure intl
RUN docker-php-ext-install bcmath intl sockets sodium
RUN docker-php-ext-enable opcache ds bcmath yaml sodium

FROM ghcr.io/roadrunner-server/roadrunner:latest AS rr
FROM base AS roadrunner

COPY --from=rr /usr/bin/rr "${LOCAL_BIN_PATH}/rr"

FROM roadrunner AS dev
ENV APP_ENV=dev
ENV XDEBUG_MODE=coverage
RUN pecl install xdebug
RUN docker-php-ext-enable xdebug

COPY ./ini/php.ini-development /usr/local/etc/php/php.ini
COPY ./ini/conf.d/dev/* /usr/local/etc/php/conf.d/
COPY --from=composer:latest /usr/bin/composer "${LOCAL_BIN_PATH}/composer"

FROM base AS prod
ENV APP_ENV=prod

LABEL maintainer="Barney Hanlon <symfony@shrikeh.net>"
