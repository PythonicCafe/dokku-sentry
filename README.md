![Project logo](.github/header.png)

![Sentry version](https://img.shields.io/badge/Sentry-9.1-blue.svg) ![Dokku version](https://img.shields.io/badge/Dokku-v0.14.6-blue.svg)

# Run Sentry on Dokku

Deploy your own instance of [Sentry](https://sentry.io) onto
[Dokku](https://github.com/dokku/dokku)!

This project is a clone of the official bootstrap repository
([getsentry/onpremise](https://github.com/getsentry/onpremise)) with a few
modifications for a seamless deploy to Dokku.

## What you get

This repository will deploy [Sentry
9.1](https://github.com/getsentry/sentry/releases/tag/9.1.0). It has been tested
with Dokku 0.10+.

## Requirements

 * [Dokku](https://github.com/dokku/dokku)
 * [dokku-postgres](https://github.com/dokku/dokku-postgres)
 * [dokku-redis](https://github.com/dokku/dokku-redis)
 * [dokku-memcached](https://github.com/dokku/dokku-memcached)
 * [dokku-letsencrypt](https://github.com/dokku/dokku-letsencrypt)

# Upgrading

When upgrading to a newer version, e.g. 8.22 to 9.1.0, you just need to follow
the following steps:

First get the newest version of this repository from GitHub and push it to you
Dokku host:

```bash
git pull
git push dokku master
```

During the deploy, Dokku will run all commands that are necessary to upgrade the
database to the newest version. You do not need to do anything else.

# Setup

This will guide you through the set up of a new Sentry instance. Make sure to
follow these steps one after another.

## App and databases

First create a new Dokku app. We'll call it `sentry`.

```
dokku apps:create sentry
```

Next we create the databases needed by Sentry and link them.

```
dokku postgres:create sentry_postgres
dokku postgres:link sentry_postgres sentry

dokku redis:create sentry_redis
dokku redis:link sentry_redis sentry

dokku memcached:create sentry_memcached
dokku memcached:link sentry_memcached sentry
```

## Configuration

### Set a secret key

```
dokku config:set --no-restart sentry SENTRY_SECRET_KEY=$(echo `openssl rand -base64 64` | tr -d ' ')
```

### Email settings

If you want to receive emails from sentry (notifications, activation mails), you
need to set the following settings accordingly.

```
dokku config:set --no-restart sentry SENTRY_EMAIL_HOST=smtp.example.com
dokku config:set --no-restart sentry SENTRY_EMAIL_PASSWORD=<yourmailpassword>
dokku config:set --no-restart sentry SENTRY_EMAIL_PORT=25
dokku config:set --no-restart sentry SENTRY_EMAIL_USER=<yourusername>
dokku config:set --no-restart sentry SENTRY_EMAIL_USE_TLS=True
dokku config:set --no-restart sentry SENTRY_SERVER_EMAIL=sentry@example.com
dokku config:set --no-restart sentry SENTRY_USE_SSL=False
```

## Persistent storage

To persists user uploads (e.g. avatars) between restarts, we create a folder on
the host machine and tell Dokku to mount it to the app container.

```
sudo mkdir -p /var/lib/dokku/data/storage/sentry
sudo chown 32768:32768 /var/lib/dokku/data/storage/sentry
dokku storage:mount sentry /var/lib/dokku/data/storage/sentry:/var/lib/sentry/files
```

## Domain setup

To get the routing working, we need to apply a few settings. First we set
the domain.

```
dokku domains:set sentry sentry.example.com
```


## Push Sentry to Dokku

### Grabbing the repository

First clone this repository onto your machine.

#### Via SSH

```
git clone git@github.com:mimischi/dokku-sentry.git
```

#### Via HTTPS

```
git clone https://github.com/mimischi/dokku-sentry.git
```

### Set up git remote

Now you need to set up your Dokku server as a remote.

```
git remote add dokku dokku@example.com:sentry
```

### Push Sentry

Now we can push Sentry to Dokku (_before_ moving on to the [next part](#domain-and-ssl-certificate)).

```
git push dokku main
```

## SSL certificate

Last but not least, we can go an grab the SSL certificate from [Let's
Encrypt](https://letsencrypt.org/).

```
dokku letsencrypt:set email you@example.com
dokku letsencrypt:enable sentry
```

## Create a user

Sentry is now up and running on your domain ([https://sentry.example.com](#)).
Before you're able to use it, you need to create a user.

```
dokku run sentry sentry createuser
```

This will prompt you to enter an email, password and whether the user should be a superuser.
