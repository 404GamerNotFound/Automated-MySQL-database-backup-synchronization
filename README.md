# Remote MySQL Backup and Restore Script

This repository contains a shell script (`syncMySQLDB.sh`) for backing up a MySQL database from a remote server and restoring it to a local MySQL server. The script will replace the existing data in the local database if a database with the same name exists. If the dump is empty, it will not overwrite anything.

## Prerequisites

Before running this script, ensure the following conditions are met:

1. SSH key-based authentication is set up for the remote server you're connecting to.
2. `mysqldump` is available on the remote server, and `mysql` is available on the local server.
3. The user executing the script has write permissions to the directory where the backup will be stored.
4. The local MySQL user has the necessary permissions to drop and create databases.

## Configuration

1. Clone this repository to your local server where you want to store the backup.
2. Open the `backup_script.sh` file in a text editor.
3. Update the following variables with the appropriate values for your remote and local server configurations:

```bash
REMOTE_USER="remote_username"
REMOTE_HOST="remote_host"
REMOTE_DB_USER="remote_db_user"
REMOTE_DB_PASSWORD="remote_db_password"
REMOTE_DB_NAME="remote_database_name"
LOCAL_DB_USER="local_db_user"
LOCAL_DB_PASSWORD="local_db_password"
LOCAL_DB_NAME="local_database_name"
```
## Usage

To use the script, follow these steps:

1. Make the script executable by running: `chmod +x backup_script.sh`.
2. Execute the script: `./backup_script.sh`.

## Important Notes

- **Security**: Your database password is included in the script. For a production environment, it's recommended to use a `.my.cnf` file to store your MySQL credentials securely.
- **Data Loss**: This script will DROP the local database if it exists and create a new one. Ensure that you have adequate backups before running this script.
- **Testing**: Always test the script in a non-production environment before running it on production servers.

## Troubleshooting

If the script fails, check the following:

- SSH connection to the remote server is working without manual intervention.
- Correct database user credentials are provided for both the remote and local servers.
- The local MySQL user has the necessary permissions to drop and create databases.

## Contributing

Feel free to fork this repository and contribute by submitting a pull request with your improvements.

## License

This script is released under the MIT License. See the `LICENSE` file for details.

## Disclaimer

The author is not responsible for any potential data loss. Use this script at your own risk.

## Support

If you encounter any issues or have any questions, please file an issue in the GitHub repository.
