FROM sentry:9.1.2-onbuild

ENV PYTHONUNBUFFERED=1

# Create a non-root user to run the app
RUN addgroup --gid ${GID:-1000} django \
  && adduser --disabled-password --gecos "" --home /app --uid ${UID:-1000} --gid ${GID:-1000} django \
  && chown -R django:django /app

# Fix Debian repository, upgrade packages and install wget
RUN echo "deb http://archive.debian.org/debian stretch main contrib non-free" > /etc/apt/sources.list \
  && echo "deb http://archive.debian.org/debian-security stretch/updates main contrib non-free" >> /etc/apt/sources.list \
  && apt update \
  && apt upgrade -y \
  && apt install --no-install-recommends -y wget \
  && apt purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && apt clean \
  && rm -rf /var/lib/apt/lists/*

# Download a free GeoIP database
RUN rm -rf /opt/geoip && \
    mkdir -p /opt/geoip && \
    cd /opt/geoip && \
    wget -c -t 5 "https://download.db-ip.com/free/dbip-city-lite-2025-02.mmdb.gz" && \
    gunzip "dbip-city-lite-2025-02.mmdb.gz"

USER django
