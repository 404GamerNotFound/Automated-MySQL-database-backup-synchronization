#!/bin/bash

# Remote MySQL Backup and Restore Script
#
# This script backs up a MySQL database from a remote server and restores it to a local MySQL server.
# It will replace the existing data in the local database if a database with the same name exists.
# If the dump is empty, it will not overwrite anything.
#
# Prerequisites:
# - SSH key-based authentication set up for the remote server.
# - 'mysqldump' available on the remote server and 'mysql' available on the local server.
# - Write permissions in the directory where the script is running.
# - Local MySQL user permissions to drop and create databases.
#
# Usage:
# 1. Make the script executable: chmod +x backup_script.sh
# 2. Execute the script: ./backup_script.sh
#
# Ensure that you have a backup and have tested this script in a non-production environment.
#
# The author is not responsible for any potential data loss. Use at your own risk.

# Set variables
REMOTE_USER="remote_username"
REMOTE_HOST="remote_host"
REMOTE_DB_USER="remote_db_user"
REMOTE_DB_PASSWORD="remote_db_password"
REMOTE_DB_NAME="remote_database_name"
LOCAL_DB_USER="local_db_user"
LOCAL_DB_PASSWORD="local_db_password"
LOCAL_DB_NAME="local_database_name"
DUMP_FILE="backup_$(date +%Y%m%d%H%M%S).sql"

# Ensuring SSH key-based authentication is set up
if ! ssh -o BatchMode=yes -o ConnectTimeout=5 ${REMOTE_USER}@${REMOTE_HOST} echo ok 2>&1; then
    echo "SSH key-based authentication to ${REMOTE_HOST} failed."
    exit 1
fi

# Checking for required commands mysqldump and mysql
if ! command -v mysqldump &> /dev/null; then
    echo "mysqldump could not be found on the remote server."
    exit 1
fi

if ! command -v mysql &> /dev/null; then
    echo "mysql could not be found on the local server."
    exit 1
fi

# Ensuring the user has write permissions in the current directory
if ! touch test_write_permission 2>/dev/null; then
    echo "You do not have write permissions in the current directory."
    rm -f test_write_permission
    exit 1
fi
rm -f test_write_permission

# Ensuring the local MySQL user has DROP and CREATE permissions
if ! mysql -u "${LOCAL_DB_USER}" -p"${LOCAL_DB_PASSWORD}" -e "DROP DATABASE IF EXISTS test_db_permission; CREATE DATABASE test_db_permission;" &> /dev/null; then
    echo "The local MySQL user does not have DROP and CREATE permissions."
    exit 1
fi
mysql -u "${LOCAL_DB_USER}" -p"${LOCAL_DB_PASSWORD}" -e "DROP DATABASE test_db_permission;" &> /dev/null

# Removing existing dump file if present
rm -f "${DUMP_FILE}"

# Logging into the remote server via SSH and creating a MySQL dump
ssh "${REMOTE_USER}@${REMOTE_HOST}" "mysqldump -u '${REMOTE_DB_USER}' -p'${REMOTE_DB_PASSWORD}' '${REMOTE_DB_NAME}' --single-transaction" > "${DUMP_FILE}"

# Checking if the dump is empty
if [ ! -s "${DUMP_FILE}" ]; then
    echo "The SQL dump is empty. The script will exit without overwriting anything."
    exit 1
fi

# Dropping the existing local database and recreating it
mysql -u "${LOCAL_DB_USER}" -p"${LOCAL_DB_PASSWORD}" -e "DROP DATABASE IF EXISTS ${LOCAL_DB_NAME}; CREATE DATABASE ${LOCAL_DB_NAME};"

# Importing the SQL dump into the local database
mysql -u "${LOCAL_DB_USER}" -p"${LOCAL_DB_PASSWORD}" "${LOCAL_DB_NAME}" < "${DUMP_FILE}"

# Checking if the import was successful
if [ $? -eq 0 ]; then
    echo "The database dump has been successfully imported into the local database ${LOCAL_DB_NAME}."
else
    echo "There was an error importing the dump into the local database."
    exit 1
fi

# Cleaning up the dump file
rm -f "${DUMP_FILE}"

echo "Backup and restore operations completed successfully."
