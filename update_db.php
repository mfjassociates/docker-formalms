<?php
// filepath: /app/update_ldap_settings.php

// Database configuration - replace with your connection values
// Load environment variables
$db_host = getenv('DB_HOST');
$db_user = getenv('DB_USER');
$db_pass = file_get_contents('/run/secrets/formalms_db_pw');
$db_name = getenv('DB_NAME');

// Connect to database
$conn = new mysqli($db_host, $db_user, $db_pass, $db_name);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

echo "Connected successfully to database.\n";

// Update ldap_port with all fields
$update_sql1 = "
UPDATE `$db_name`.`core_setting` 
SET `param_value` = '389',
    `value_type` = 'string',
    `max_size` = 5,
    `pack` = '0',
    `sequence` = 1,
    `param_load` = 1,
    `hide_in_modify` = 0,
    `extra_info` = ''
WHERE `param_name` = 'ldap_port' AND `regroup` = 9";

// Update ldap_used with all fields
$update_sql2 = "
UPDATE `$db_name`.`core_setting` 
SET `param_value` = 'on',
    `value_type` = 'enum',
    `max_size` = 3,
    `pack` = '0',
    `sequence` = 2,
    `param_load` = 1,
    `hide_in_modify` = 0,
    `extra_info` = ''
WHERE `param_name` = 'ldap_used' AND `regroup` = 9";

// Update ldap_server with all fields
$update_sql3 = "
UPDATE `$db_name`.`core_setting` 
SET `param_value` = '" . getenv('LDAP_SERVER') . "',
    `value_type` = 'string',
    `max_size` = 255,
    `pack` = '0',
    `sequence` = 3,
    `param_load` = 1,
    `hide_in_modify` = 0,
    `extra_info` = ''
WHERE `param_name` = 'ldap_server' AND `regroup` = 9";

// Update ldap_user_string with all fields
$update_sql4 = "
UPDATE `$db_name`.`core_setting` 
SET `param_value` = '" . getenv('LDAP_USER_STRING') . "',
    `value_type` = 'string',
    `max_size` = 255,
    `pack` = 'email_settings',
    `sequence` = 4,
    `param_load` = 1,
    `hide_in_modify` = 0,
    `extra_info` = ''
WHERE `param_name` = 'ldap_user_string' AND `regroup` = 9";

// Execute each update
if ($conn->query($update_sql1) === TRUE) {
    echo "LDAP port setting updated successfully.\n";
} else {
    echo "Error updating LDAP port: " . $conn->error . "\n";
}

if ($conn->query($update_sql2) === TRUE) {
    echo "LDAP used setting updated successfully.\n";
} else {
    echo "Error updating LDAP used setting: " . $conn->error . "\n";
}

if ($conn->query($update_sql3) === TRUE) {
    echo "LDAP server setting updated successfully.\n";
} else {
    echo "Error updating LDAP server: " . $conn->error . "\n";
}

if ($conn->query($update_sql4) === TRUE) {
    echo "LDAP user string setting updated successfully.\n";
} else {
    echo "Error updating LDAP user string: " . $conn->error . "\n";
}

// Check if ldap_alternate_check already exists
$check_sql = "SELECT COUNT(*) AS count FROM `$db_name`.`core_setting` WHERE `param_name` = 'ldap_alternate_check'";
$result = $conn->query($check_sql);
$row = $result->fetch_assoc();

if ($row['count'] == 0) {
    // Insert the ldap_alternate_check setting
    $insert_sql = "
    INSERT INTO `$db_name`.`core_setting` 
    (`param_name`,           `param_value`,                            `value_type`, `max_size`, `pack`, `regroup`, `sequence`, `param_load`, `hide_in_modify`, `extra_info`) 
    VALUES 
    ('ldap_alternate_check', '" . getenv('LDAP_ALTERNATE_CHECK') . "', 'enum',        3,         '0',     9,         14,         1,            0,                '')
    ";

    if ($conn->query($insert_sql) === TRUE) {
        echo "LDAP alternate check setting added successfully.\n";
    } else {
        echo "Error inserting ldap_alternate_check: " . $conn->error . "\n";
    }
} else {
    echo "ldap_alternate_check already exists in the database.\n";
}

$conn->close();
echo "Database connection closed.\n";
?>