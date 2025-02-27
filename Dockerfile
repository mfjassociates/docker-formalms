FROM php:8.1-apache-bullseye
ARG VERSION=4.0.11

ENV APACHE_DOCUMENT_ROOT /app/formalms

# Install necessary packages
RUN \
  echo "**** install final packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    dnsutils \
    iproute2 \
    vim \
    unzip \
    wget && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Enable mod_rewrite
RUN a2enmod rewrite

# Download and unzip formalms
# Very important, the formalms zip MUST BE unzipped in a subfolder of the /app directory
# failure to do that will result in ..Lms URL to be generated after login
RUN \
  echo "**** download formalms ****" && \
  wget -O formalms.zip https://sourceforge.net/projects/forma/files/version-4.x/formalms-${VERSION}.zip/download && \
  mkdir -p /app && \
  unzip formalms.zip -d /app && \
  ls -la /app && \
  rm formalms.zip

WORKDIR /app
RUN \
  cp formalms/config.dist.php formalms/config.php && \
  docker-php-ext-configure mysqli && \
  docker-php-ext-install mysqli && \
  docker-php-ext-install pdo pdo_mysql && \
  sed -ri -e "s!/var/www/html!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/sites-available/*.conf && \
  sed -ri -e "s!/var/www/!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf && \
  chown www-data:www-data -R /app

# Define volumes and expose ports
VOLUME /app
EXPOSE 80 443
