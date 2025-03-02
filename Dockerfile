# Updated with recent versions of dependencies
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
    wget \
    libldap2-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  echo "**** install ldap ****" && \
  docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
  docker-php-ext-install ldap

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

COPY ldap-config.sh /usr/local/bin/ldap-config.sh
RUN chmod +x /usr/local/bin/ldap-config.sh
COPY update_db.php /app/formalms/update_db.php
COPY php.ini /usr/local/etc/php/php.ini

# Create and apply LDAP patch to use LDAP v3 protocol
RUN echo 'diff --git a/FormaUser.php b/FormaUser.php\n--- a/FormaUser.php\n+++ b/FormaUser.php\n@@ -622,6 +622,8 @@\n             if (!($ldap_conn = @ldap_connect(Get::sett('\''ldap_server'\''), Get::sett('\''ldap_port'\'', '\''389'\'')))) {\n                 exit('\''Could not connect to ldap server'\'');\n             }\n+            ldap_set_option($ldap_conn, LDAP_OPT_PROTOCOL_VERSION, 3);\n+            ldap_set_option($ldap_conn, LDAP_OPT_REFERRALS, 0);\n \n             //bind on server\n             $ldap_user = preg_replace('\''/\\$user/'\'', $login, Get::sett('\''ldap_user_string'\''));' > /tmp/ldap.patch && \
    if [ -f /app/formalms/lib/FormaUser.php ]; then \
      echo "Applying LDAP v3 protocol patch..." && \
      patch /app/formalms/lib/FormaUser.php /tmp/ldap.patch && \
      rm /tmp/ldap.patch && \
      echo "LDAP patch applied successfully"; \
    else \
      echo "WARNING: FormaUser.php not found, LDAP patch not applied"; \
    fi

# Do not unbind LDAP connection twice when using LDAP alternate check
RUN echo 'diff --git a/html/lib/FormaUser.php b/html/lib/FormaUser.php\nindex 0ba4febdd..aee9afa1b 100755\n--- a/html/lib/FormaUser.php\n+++ b/html/lib/FormaUser.php\n@@ -639,8 +639,9 @@ class FormaUser\n                     return $false_public;\n                 }\n                 // End edit\n+            } else {\n+                ldap_unbind($ldap_conn);\n             }\n-            ldap_unbind($ldap_conn);\n         } elseif (!$user_manager->password_verify_update($password, $user_info[ACL_INFO_PASS], $user_info[ACL_INFO_IDST])) {\n             return false;\n         }\n-- \n' >/tmp/ldap-unbind.patch && \
    if [ -f /app/formalms/lib/FormaUser.php ]; then \
      echo "Applying LDAP unbind patch..." && \
      patch /app/formalms/lib/FormaUser.php /tmp/ldap-unbind.patch && \
      rm /tmp/ldap-unbind.patch && \
      echo "LDAP unbind patch applied successfully"; \
    else \
      echo "WARNING: FormaUser.php not found, LDAP unbind patch not applied"; \
    fi
# Install required PHP extensions and configure Apache to use /app/formalms as document root
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
