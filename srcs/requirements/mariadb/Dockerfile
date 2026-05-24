
# We are asked to use penultimate which is the one before the latest
# The current latest is 13, so penultimate is 12
FROM debian:12

# 1. Install MariaDB Server
# 2. Clean package cache to reduce image size as they are only needed during install
# -y: auto confirms installation without prompts
RUN apt-get update -y && apt-get upgrade -y \
    && apt-get install -y mariadb-server \
    && rm -rf /var/lib/apt/lists/*

# Create directories to store PID file and Unix socket
# Given permission to create PID and socket files
# MariaDB needs a place to write runtime files and docker gives a minial filesystem
# So we must prepare the directory
RUN mkdir -p /var/run/mysqld \
    && chown -R mysql:mysql /var/run/mysqld \
    && chmod 777 /var/run/mysqld

# Initialise entrypoint script
# ENV var only exist when the container starts, at runtime
# Hence any code that relies on these env vars must run inside the container i.e. script.sh
COPY tools/script.sh /usr/local/bin/script.sh
RUN chmod +x /usr/local/bin/script.sh

# configure network [OPTIONAL]
# By default, MariaDB binds to 127.0.0.1
COPY conf/my.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Tells Docker that this container listens on port 3306
EXPOSE 3306

# Execute this script as the main process
ENTRYPOINT [ "/usr/local/bin/script.sh" ]

# Build time (docker build):
#    Start Debian 12
#         ↓
#    Install MariaDB
#         ↓
#    Create /var/run/mysqld folder
#         ↓
#    Copy script.sh into image
#         ↓
#    Copy my.cnf config into image
#         ↓
#    Image is ready

# Runtime (docker run / make start):
#    Container starts
#         ↓
#    script.sh runs
#         ↓
#    MariaDB sets up database, users, passwords
        # ↓
#    MariaDB starts listening on port 3306
