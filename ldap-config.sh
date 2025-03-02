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

# call update_db.php to update the database
#php /app/formalms/update_db.php
# Start Apache
apache2-foreground