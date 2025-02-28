#!/bin/sh
# filepath: ldap-config.sh

# Exit immediately if any command fails
set -e

# Optional: Treat unset variables as errors
set -u

# Read the content of the secret file into a variable
pw=$(cat /run/secrets/ldap_bind_pw)
db_pw=$(cat /run/secrets/formalms_db_pw)

# Configure database settings
sed -i "s|cfg\\['db_host'\\] = 'localhost'|cfg['db_host'] = '${DB_HOST}'|" /app/formalms/config.php
sed -i "s|cfg\\['db_user'\\] = 'root'|cfg['db_user'] = '${DB_USER}'|" /app/formalms/config.php
sed -i "s|cfg\\['db_pass'\\] = ''|cfg['db_pass'] = '${db_pw}'|" /app/formalms/config.php
sed -i "s|cfg\\['db_name'\\] = 'forma'|cfg['db_name'] = '${DB_NAME}'|" /app/formalms/config.php

# Check if LDAP settings already exist
if ! grep -q "cfg\['user_pwd_type'\]" /app/formalms/config.dist.php; then
  echo "
  // LDAP Configuration
  \$cfg['user_pwd_type'] = 'ldap';
  \$cfg['ldap_host'] = '${LDAP_HOST}';
  \$cfg['ldap_port'] = '${LDAP_PORT}';
  \$cfg['ldap_base_dn'] = '${LDAP_BASE_DN}';
  \$cfg['ldap_bind_dn'] = '${LDAP_BIND_DN}';
  \$cfg['ldap_bind_password'] = '${pw}';
  \$cfg['ldap_filter'] = '${LDAP_USER_FILTER}';
  \$cfg['ldap_user_attr'] = '${LDAP_USERNAME_ATTRIBUTE}';
  \$cfg['ldap_realname_attr'] = '${LDAP_REALNAME_ATTRIBUTE}';
  \$cfg['ldap_email_attr'] = '${LDAP_EMAIL_ATTRIBUTE}';
  " >> /app/formalms/config.dist.php
  echo "LDAP settings added to config.php"
else
  echo "LDAP settings already exist in config.php"
fi
# Start Apache
apache2-foreground