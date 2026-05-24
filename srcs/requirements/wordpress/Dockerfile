FROM debian:12

# php: install PHP itself as WordPress is writtern in PHP
# php-fpm: Nginx cannot execute PHP so we need PHP-FPM runs PHP and listens on port 9000
# php-mysql: WordPress can store everything in MariaDB
# php-gd: Handle image processing
# php-curl: Make external requests
# php-mbstring: Handles multibyte string operations
# php-xml: XML parsing
# php-redis: to Connect PHP with Redis
# mariadb-client: test DB availability (debugging)
# curl: download files from the Internet (needed for WP-CLI)
RUN apt-get update && \
    apt-get install -y \
    php \
    php-fpm \
    php-mysql \
    php-gd \
    php-curl \
    php-mbstring \
    php-redis \
    php-xml \
    curl \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# /var/www/html is the web root
WORKDIR /var/www/html

# PHP-FPM needs permission to read/write WordPress files
# WP-CLI (WordPress Command Line Interface) is a command-line tool for managing WordPress without using a web browser
# chown -R www-data:www-data: recursively changes owner/group to the user PHP-FPM runs as
# chmod -R 755: sets permissions owner can read/write/execute, others can read/execute
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

# Download WP-CLI
# curl -O: Downloads wp-cli.phar
# In order to run WordPress commands like wp core install from the terminal
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp
RUN sed -i "s|listen = /run/php/php8.2-fpm.sock|listen = 9000|" /etc/php/8.2/fpm/pool.d/www.conf

EXPOSE 9000

COPY ./tools/script.sh .
RUN chmod +x script.sh

ENTRYPOINT ["bash", "script.sh"]

