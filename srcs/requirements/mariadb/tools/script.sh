#!/bin/bash

# Exit immediately if any commands fails
set -e

# Retrieve sensitive data
DB_ROOT_PASS=$(cat /run/secrets/db_root)
DB_USER_PASS=$(cat /run/secrets/db_user)

# Initialize DB only if it doesn't exist
# Check to prevent overwriting existing DB
if [ ! -e /var/lib/mysql/.firstmount ]; then
    echo "Initializing MariDB database..."

    # --user=msql: Ensures that all files are owned by the mysql user, not root
    # --datadir=/var/lib/mysql: Specifies where to initialize the database (where all DB files will be stored)
    mariadb-install-db \
			--user=mysql \
	        --basedir=/usr \
	        --datadir=/var/lib/mysql \
	        --auth-root-authentication-method=socket \
	        --skip-test-db \
	        >/dev/null 2>&1

    # mariadbd-safe: monitors the server and restarts it if it crashes
    # --user=mysql: ensures the server runs as the mysql user (required for permissions)
    # &: means run in background, so the script continues
    mariadbd-safe --user=mysql &

    # Wait until MariaDB is ready
    # >/dev/null 2>&1: discard all the output, so the terminal stays clean
    until mariadb -u root -e "SELECT 1;" >/dev/null 2>&1; do
        echo "MariaDB not started yet..."
        sleep 1
    done

    # Creates our application database (if it doesn’t exist)
	mariadb -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME}"

    # Creates a new MariaDB user for our application
    # '%' means the user can connect from any host, which is needed in Docker networks
    # Security best practice: don’t allow app user to log in as root or from localhost inside the DB container
	mariadb -e "CREATE USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_USER_PASS}';"

    # Grants full permissions on our application database to the new user
	mariadb -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';"

    # Sets the root password
    # Required: MariaDB may create a root account without a password during initial install
	mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';"

    # Reloads privileges so that changes to user passwords and grants take effect immediately
	mariadb -u root -p${DB_ROOT_PASS} -e "FLUSH PRIVILEGES;"

    # Stops the background MariaDB server safely
    # Ensures no conflicts when the container starts the foreground server at the end of the script
	mariadb-admin -u root -p${DB_ROOT_PASS} shutdown

    # Create marker file to indicate initialization is complete
    touch /var/lib/mysql/.firstmount

	echo "Mariadb Successful"
fi

# Starts MariaDB in the foreground (Set MariaDB as PID 1)
# Docker requires the main process to run in foreground, otherwise the container exits
# This is the server that the container will keep running
exec mariadbd-safe --user=mysql

# Container starts
#       ↓
# Read passwords from secret files
#       ↓
# Does .firstmount exist?
#       ↓
# NO → initialise database files
#       ↓
#      Start MariaDB in background temporarily
#       ↓
#      Wait until MariaDB is ready
#       ↓
#      Create database
#      Create DB_USER
#      Set permissions
#      Set root password
#       ↓
#      Shutdown background MariaDB
#      Create .firstmount marker
#       ↓
# YES → skip all setup
#       ↓
# Start MariaDB in foreground — container keeps running
