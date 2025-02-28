#!/bin/sh
# filepath: /z:/portainer/data/docker-formalms/ldap-config.sh

# Read the content of the secret file into a variable
pw=$(cat /run/secrets/ldap_bind_pw)

# Configure database settings
sed -i "s|cfg\\['db_host'\\] = 'localhost'|cfg['db_host'] = '${DB_HOST}'|" /app/formalms/config.php
sed -i "s|cfg\\['db_user'\\] = 'root'|cfg['db_user'] = '${DB_USER}'|" /app/formalms/config.php
sed -i "s|cfg\\['db_pass'\\] = ''|cfg['db_pass'] = '${1}'|" /app/formalms/config.php
sed -i "s|cfg\\['db_name'\\] = 'forma'|cfg['db_name'] = '${DB_NAME}'|" /app/formalms/config.php

# Configure LDAP settings
sed -i "s|cfg\\['user_pwd_type'\\] = ''|cfg['user_pwd_type'] = 'ldap'|" /app/formalms/config.php
sed -i "s|cfg\\['ldap_host'\\] = ''|cfg['ldap_host'] = '${LDAP_HOST}'|" /app/formalms/config.php
sed -i "s|cfg\\['ldap_port'\\] = ''|cfg['ldap_port'] = '${LDAP_PORT}'|" /app/formalms/config.php
sed -i "s|cfg\\['ldap_base_dn'\\] = ''|cfg['ldap_base_dn'] = '${LDAP_BASE_DN}'|" /app/formalms/config.php
sed -i "s|cfg\\['ldap_bind_dn'\\] = ''|cfg['ldap_bind_dn'] = '${LDAP_BIND_DN}'|" /app/formalms/config.php
sed -i "s|cfg\\['ldap_bind_password'\\] = ''|cfg['ldap_bind_password'] = '${pw}'|" /app/formalms/config.php
sed -i "s|cfg\\['ldap_filter'\\] = ''|cfg['ldap_filter'] = '${LDAP_USER_FILTER}'|" /app/formalms/config.php
sed -i "s|cfg\\['ldap_user_attr'\\] = ''|cfg['ldap_user_attr'] = '${LDAP_USERNAME_ATTRIBUTE}'|" /app/formalms/config.php
sed -i "s|cfg\\['ldap_realname_attr'\\] = ''|cfg['ldap_realname_attr'] = '${LDAP_REALNAME_ATTRIBUTE}'|" /app/formalms/config.php
sed -i "s|cfg\\['ldap_email_attr'\\] = ''|cfg['ldap_email_attr'] = '${LDAP_EMAIL_ATTRIBUTE}'|" /app/formalms/config.php

# Start Apache
apache2-foreground