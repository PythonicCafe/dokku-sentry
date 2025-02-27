![Project logo](.github/header.png)

![Sentry version](https://img.shields.io/badge/Sentry-9.1-blue.svg) ![Dokku version](https://img.shields.io/badge/Dokku-v0.14.6-blue.svg)

# Deploy Sentry on Dokku

Deploy your own instance of [Sentry](https://sentry.io) onto [Dokku](https://github.com/dokku/dokku)!

This project is a clone of the official bootstrap repository
([getsentry/onpremise](https://github.com/getsentry/onpremise)) with a few modifications for a seamless deploy to
Dokku.

## What you get

This repository will deploy [Sentry 9.1.2](https://github.com/getsentry/sentry/releases/tag/9.1.2). It has been tested
with Dokku 0.10+.

## Requirements

- [Dokku](https://github.com/dokku/dokku)
- [dokku-postgres](https://github.com/dokku/dokku-postgres)
- [dokku-redis](https://github.com/dokku/dokku-redis)
- [dokku-memcached](https://github.com/dokku/dokku-memcached)
- [dokku-letsencrypt](https://github.com/dokku/dokku-letsencrypt)


## Setup

First, copy the block below and change de variables for values of your liking. Then, execute in the Dokku server.

```
export APP_NAME="sentry"
export APP_DOMAIN="sentry.example.com"
export LETSENCRYPT_EMAIL="admin@example.com"
export PG_NAME="pg_${APP_NAME}"
export REDIS_NAME="redis_${APP_NAME}"
export MEMCACHED_NAME="memcached_${APP_NAME}"
export EMAIL_HOST="smtp.example.com"
export EMAIL_PASSWORD="<your-mail-password>"
export EMAIL_PORT="25"
export EMAIL_USERNAME="<your-username>"
export EMAIL_USE_TLS="True"
export EMAIL_SENDER="sentry@example.com"
export EMAIL_USE_SSL="False"
export HOST_STORAGE_PATH="/var/lib/dokku/data/storage/${APP_NAME}"
export CONTAINER_STORAGE_PATH="/data"

dokku apps:create "$APP_NAME"
dokku domains:set "$APP_NAME" $APP_DOMAIN
dokku config:set --no-restart "$APP_NAME" SENTRY_SECRET_KEY=$(echo `openssl rand -base64 64` | tr -d ' ')
dokku config:set --no-restart "$APP_NAME" SENTRY_EMAIL_HOST=$EMAIL_HOST
dokku config:set --no-restart "$APP_NAME" SENTRY_EMAIL_PASSWORD=$EMAIL_PASSWORD
dokku config:set --no-restart "$APP_NAME" SENTRY_EMAIL_PORT=$EMAIL_PORT
dokku config:set --no-restart "$APP_NAME" SENTRY_EMAIL_USER=$EMAIL_USERNAME
dokku config:set --no-restart "$APP_NAME" SENTRY_EMAIL_USE_TLS=$EMAIL_USE_TLS
dokku config:set --no-restart "$APP_NAME" SENTRY_SERVER_EMAIL=$EMAIL_SENDER
dokku config:set --no-restart "$APP_NAME" SENTRY_USE_SSL=$EMAIL_USE_SSL
dokku config:set --no-restart "$APP_NAME" SENTRY_FILESTORE_DIR=$CONTAINER_STORAGE_PATH

dokku postgres:create "$PG_NAME" --image-version 17-bookworm
dokku postgres:link "$PG_NAME" "$APP_NAME"
dokku redis:create "$REDIS_NAME" --image-version 5.0.14-alpine
dokku redis:link "$REDIS_NAME" "$APP_NAME"
dokku memcached:create "$MEMCACHED_NAME" --image-version 1.5.20
dokku memcached:link "$MEMCACHED_NAME" "$APP_NAME"

mkdir -p "$HOST_STORAGE_PATH"
chown -R 1000:1000 "$HOST_STORAGE_PATH"  # `django` user inside container have UID=GID=1000
dokku storage:mount $APP_NAME "$HOST_STORAGE_PATH:$CONTAINER_STORAGE_PATH"
```

Now, clone this repository **on your marchine**, setup the Dokku server as remote and execute the first deploy:

```shell
git clone git@github.com:PythonicCafe/dokku-sentry.git
cd dokku-sentry
git remote add dokku dokku@<your-dokku-server>:<app-name>
git push dokku main
```

Now, go back to the server and execute:

```shell
dokku letsencrypt:set "$APP_NAME" email "$LETSENCRYPT_EMAIL"
dokku letsencrypt:enable "$APP_NAME"
```

And, finally, create a user:

```shell
dokku run "$APP_NAME" sentry createuser
```

Your Sentry instance is now running and configured!
