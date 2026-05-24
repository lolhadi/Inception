# Inception - Dev Doc

## Environment

- Secret files for passwords stored in `secrets/` folder — one level above `srcs/`
- Environment variables for non-sensitive config stored in `srcs/.env`
- Config files for MariaDB and Nginx inside their respective `conf/` folders
- Setup scripts for MariaDB and WordPress inside their respective `tools/` folders

## Project Structure

```
Inception/
├── Makefile
├── secrets/
│   ├── db_root_password.txt
│   ├── db_password.txt
│   ├── wp_admin_password.txt
│   ├── wp_user_password.txt
│   └── ftp_user_password.txt
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── my.cnf
        │   └── tools/
        │       └── script.sh
        ├── wordpress/
        │   ├── Dockerfile
        │   └── tools/
        │       └── script.sh
        └── nginx/
            ├── Dockerfile
            └── conf/
                └── nginx.conf
```

## Commands

### Makefile
- **make** — build images and start all containers
- **make build** — create data folders and build all Docker images
- **make start** — start all containers in background
- **make logs** — display logs from all containers
- **make stop** — stop all containers without removing them
- **make clean** — stop and remove containers only
- **make fclean** — remove containers, images, volumes and data folders
- **make re** — full clean then full restart

### Docker (direct)
- **docker ps** — list all running containers
- **docker ps -a** — list all containers including stopped ones
- **docker logs ${container}** — display logs from a specific container
- **docker exec -it ${container} bash** — open a shell inside a running container
- **docker network ls** — list all Docker networks
- **docker volume ls** — list all Docker volumes
- **docker volume inspect ${volume}** — inspect volume details and mount path
- **docker network inspect inception** — inspect the inception network and connected containers

## Project Data

All persistent data lives inside these volumes. If a container is deleted, data remains safe in the volume. The project can be backed up by copying these directories on the host.

### Volumes

- **db** — Where MariaDB stores its data, metadata, users and settings
    - Stored at `/home/muhabin-/data/mariadb` on the VM

- **wpf** — Where WordPress files are located. Nginx and WordPress both have access
    - Stored at `/home/muhabin-/data/wordpress` on the VM
    - **WordPress** creates the original PHP files and runs them using PHP-FPM
    - **Nginx** has access to serve static content directly to clients

## Service Details

### MariaDB
- Base image: `debian:12`
- Listens on port `3306` — internal only, never exposed to outside
- Config file: `conf/my.cnf` — sets `bind-address = 0.0.0.0` so WordPress can connect
- Setup script: `tools/script.sh` — initialises database, creates users, sets passwords
- Uses `.firstmount` marker file to prevent re-initialisation on restart
- Reads secrets from `/run/secrets/db_root` and `/run/secrets/db_user`

### WordPress
- Base image: `debian:12`
- Runs PHP-FPM on port `9000` — internal only
- Uses WP-CLI to automate installation, user creation
- Setup script: `tools/script.sh` — waits for MariaDB, installs WordPress, creates two users
- Uses `wp-config.php` existence as idempotency check
- Reads secrets from `/run/secrets/wp_admin`, `/run/secrets/db_user`, `/run/secrets/wp_user`

### Nginx
- Base image: `debian:12`
- Only container exposed to outside world — port `443` only
- TLS 1.2 and TLS 1.3 only — older versions not allowed
- Self-signed SSL certificate generated during image build using OpenSSL
- Config file: `conf/nginx.conf` — handles HTTPS, routes PHP to WordPress via FastCGI
- Acts as reverse proxy — all traffic goes through Nginx first

## Environment Variables (.env)

| Variable | Used by | Purpose |
|----------|---------|---------|
| DOMAIN_NAME | Nginx, WordPress | The website domain |
| DB_NAME | MariaDB, WordPress | Name of the WordPress database |
| DB_USER | MariaDB, WordPress | Database username |
| WP_ADMIN | WordPress | Admin account username |
| WP_EMAIL | WordPress | Admin account email |
| WP_URL | WordPress | Full website URL |
| WP_USER | WordPress | Second user username |
| WP_USER_EMAIL | WordPress | Second user email |

## Secrets

| Secret file | Used by | Purpose |
|-------------|---------|---------|
| db_root_password.txt | MariaDB | Root password for MariaDB |
| db_password.txt | MariaDB, WordPress | Password for DB_USER |
| wp_admin_password.txt | WordPress | Password for WP_ADMIN |
| wp_user_password.txt | WordPress | Password for second user |

## Network

All containers communicate through a single Docker bridge network called `inception`. Containers reach each other using their service name as hostname:

- WordPress reaches MariaDB at `mariadb:3306`
- Nginx reaches WordPress at `wordpress:9000`

## Important Notes

- Never push `secrets/` or `.env` to GitHub — add them to `.gitignore`
- Always run `make fclean` before `make` if changing credentials or config
- The `/etc/hosts` file on the VM must have `127.0.0.1 muhabin-.42.fr` for the domain to resolve locally
- `restart: always` ensures containers automatically restart if they crash
- `pull_policy: never` ensures Docker never pulls images from DockerHub
