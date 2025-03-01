#!/bin/sh
# filepath: ldap-config.sh

# Exit immediately if any command fails
set -e

# Optional: Treat unset variables as errors
set -u

# Read the content of the secret file into a variable
db_pw=$(cat /run/secrets/formalms_db_pw)

# Configure database settings
sed -i "s|cfg\\['db_host'\\] = 'localhost'|cfg['db_host'] = '${DB_HOST}'|" /app/formalms/config.php
sed -i "s|cfg\\['db_user'\\] = 'root'|cfg['db_user'] = '${DB_USER}'|" /app/formalms/config.php
sed -i "s|cfg\\['db_pass'\\] = ''|cfg['db_pass'] = '${db_pw}'|" /app/formalms/config.php
sed -i "s|cfg\\['db_name'\\] = 'forma'|cfg['db_name'] = '${DB_NAME}'|" /app/formalms/config.php

# Check if LDAP settings already exist
if ! grep -q "cfg\['ldap_server'\]" /app/formalms/config.php; then
  echo "
  // LDAP Configuration
  \$cfg['ldap_server'] = '${LDAP_HOST}';
  \$cfg['ldap_port'] = '${LDAP_PORT}';
  \$cfg['ldap_user_string'] = '${LDAP_USER_STRING}';
  \$cfg['ldap_alternate_check'] = '${LDAP_ALTERNATE_CHECK}';
  \$cfg['ldap_used'] = '${LDAP_USERED}';
  " >> /app/formalms/config.php
  echo "LDAP settings added to config.php"
else
  echo "LDAP settings already exist in config.php"
fi
# Start Apache
apache2-foreground