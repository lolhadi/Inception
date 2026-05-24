#!/bin/bash
set -e

# Secrets handling
WP_ADMIN_PASS=$(cat /run/secrets/wp_admin)
DB_USER_PASS=$(cat /run/secrets/db_user)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user)

# wait for MariaDB before installing WordPress - avoids race conditions
until mariadb -h mariadb -u${DB_USER} -p${DB_USER_PASS} -e "SELECT 1;" >/dev/null 2>&1; do
	echo "Waiting for Mariadb..."
	sleep 1
done

# Idenpotency check - ensures WordPress only installs once
if [ ! -e /var/www/html/wp-config.php ]; then
    # uses WP-CLI to download the WordPress core files into the current directory
    # Docker container runs as root by default
    # WP-CLI usually refuses to run as root for safety
	wp core download --allow-root

    # Generate the main configuration file so WordPress knows how to connect to MariaDB
	wp config create --allow-root \
			--dbname=${DB_NAME} \
			--dbuser=${DB_USER} \
			--dbpass=${DB_USER_PASS} \
			--dbhost=mariadb

    # Create database tables for WordPress
    # Create the admin user and sets the site URL and site title
	wp core install --allow-root \
			--url=${DOMAIN_NAME} \
			--title=Inception \
			--admin_user=${WP_ADMIN} \
			--admin_password=${WP_ADMIN_PASS} \
			--admin_email=${WP_EMAIL} \
			--skip-email

    wp user create \
		"${WP_USER}" "${WP_USER_EMAIL}" \
		--user_pass="${WP_USER_PASSWORD}" \
		--role=author \
		--allow-root

    # ========================================
    # REDIS CONFIGURATION
    # ========================================
    echo "Configuring Redis cache..."

    # Set Redis host
    wp config set WP_REDIS_HOST redis --allow-root

    # Set Redis port (--raw means don't quote the value)
    wp config set WP_REDIS_PORT 6379 --allow-root --raw

    # Enable WordPress caching
    wp config set WP_CACHE true --allow-root --raw

    # Install and activate Redis Object Cache pluggin
    wp plugin install redis-cache --activate --allow-root

    # Enable Redis cache
    wp redis enable --allow-root

    echo "Redis cache configured and enabled!"

fi


# PHP-FPM in foreground (Set PHP-FPM as PID 1)
# -F: the process runs attached to the container, not as a background daemon
echo "WordPress Successful"
exec /usr/sbin/php-fpm8.2 -F

# Container starts
#       ↓
# Read passwords from secrets
#       ↓
# Wait until MariaDB is ready
#       ↓
# Does wp-config.php exist?
#       ↓
# NO → download WordPress core files
#       ↓
#      create wp-config.php (DB connection)
#       ↓
#      install WordPress (create DB tables)
#       ↓
#      create admin user
#      create second user
#       ↓
#      configure Redis
#      install Redis plugin
#       ↓
# YES → skip all setup
#       ↓
# Start PHP-FPM in foreground — container keeps running
