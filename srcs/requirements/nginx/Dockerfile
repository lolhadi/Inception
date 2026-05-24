FROM debian:12

# nginx: the web server (needed to serve WordPress over HTTPS)
# openssl: for generating self-signed TLS certificates
RUN apt-get update \
    && apt-get install -y nginx openssl \
    && rm -rf /var/lib/apt/lists/*

# /etc/nginx/ssl: hold TLS certificate and private key
# /var/www/html: the document root for NGINX, which will later be linked to a WordPress volume
# This ensures NGINX has a place to read website files and certificates
RUN mkdir -p /etc/nginx/ssl /var/www/html

# HTTPS requires a cert + key
# Self-signed cert: quick way to enable HTTPS for our own website when we don’t have a commercial certificate
# -x509: creates a self signed certificate
# -sha256: use SHA-256 for the cert hash
# -days 365: valid for 1 year
# -nodes: the key is unencrypted
# -out: output the certificate file
# -keyout: ouput private key
# -subj: filles certificate info automatically
#   C: country
#   ST: State
#   L: City/Location
#   O: Organization
#   OU: Organizational Unit
#   CN: Common Name (domain)
#   UID: optional user ID
RUN openssl req -x509 -sha256 -days 365 -nodes \
	-out /etc/nginx/ssl/muhabin-.crt \
	-keyout /etc/nginx/ssl/muhabin-.key \
	-subj "/C=MY/ST=SELANGOR/L=PETALINGJAYA/O=42KL/OU=muhabin-/CN=muhabin-.42.fr/UID=muhabin-"

# Set permissions
RUN chmod 755 /var/www/html
# recursively sets owner and group to www-data
# prevents permission errors when NGINX tries to read/write files
RUN chown -R www-data:www-data /var/www/html

# Copy config
# NGINX uses HTTPS only
COPY conf/nginx.conf /etc/nginx/nginx.conf

EXPOSE 443

# CMD: default command when container starts
# "daemon off;" runs in the foreground i.e. set as the PID 1 in the container
# Ensures no infinite llops, no 'tail -f', no 'sleep infinity'
CMD ["nginx", "-g", "daemon off;"]
