FROM sentry:9.1.2-onbuild

ENV PYTHONUNBUFFERED=1

# Create a non-root user to run the app
RUN addgroup --gid ${GID:-1000} django \
  && adduser --disabled-password --gecos "" --home /app --uid ${UID:-1000} --gid ${GID:-1000} django \
  && chown -R django:django /app

USER django
