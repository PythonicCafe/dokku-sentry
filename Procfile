web: gunicorn --bind=0.0.0.0:9000 --workers=2 --threads=2 --max-requests=1000 --max-requests-jitter 50 --log-file - --access-logfile - sentry.wsgi
worker: sentry --config=sentry.conf.py run worker --loglevel=INFO
beat: sentry --config=sentry.conf.py run cron --loglevel=INFO
release: sentry --config=sentry.conf.py upgrade --noinput
