#!/bin/bash

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

# Ensure the dump file does not exist before starting the dump
rm -f ${DUMP_FILE}

# Log into the remote server via SSH and create a MySQL dump
ssh ${REMOTE_USER}@${REMOTE_HOST} "mysqldump -u ${REMOTE_DB_USER} -p'${REMOTE_DB_PASSWORD}' ${REMOTE_DB_NAME} --single-transaction" > ${DUMP_FILE}

# Check if the dump is empty
if [ ! -s ${DUMP_FILE} ]; then
    echo "The SQL dump is empty. The script will exit without overwriting anything."
    exit 1
fi

# Drop existing local database and recreate it
mysql -u ${LOCAL_DB_USER} -p'${LOCAL_DB_PASSWORD}' -e "DROP DATABASE IF EXISTS ${LOCAL_DB_NAME}; CREATE DATABASE ${LOCAL_DB_NAME};"

# Import the SQL dump into the local database
mysql -u ${LOCAL_DB_USER} -p'${LOCAL_DB_PASSWORD}' ${LOCAL_DB_NAME} < ${DUMP_FILE}

# Check if the import was successful
if [ $? -eq 0 ]; then
    echo "The database dump has been successfully imported into the local database ${LOCAL_DB_NAME}."
else
    echo "There was an error importing the dump into the local database."
fi

# Clean up the dump file
rm -f ${DUMP_FILE}
