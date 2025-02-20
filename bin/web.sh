#!/bin/bash

if [ -z ${PORT+x} ]; then
	PORT=5000
fi
if [ -z ${GUNICORN_WORKERS+x} ]; then
	GUNICORN_WORKERS=4
fi

gunicorn \
	--bind 0.0.0.0:$PORT \
	--workers $GUNICORN_WORKERS \
	--max-requests 1000 \
	--max-requests-jitter 50 \
	--log-file - \
	--access-logfile - \
	sentry.wsgi
