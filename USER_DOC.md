# Inception - User Doc

## Overview of Services

| Service | Purpose |
|---------|---------|
| Nginx | Serves the WordPress website over HTTPS (port 443 only). Handles PHP requests by forwarding them to the WordPress container (PHP-FPM). Only entry point to the outside world. |
| WordPress | Provides the website content and administration panel. PHP-FPM handles PHP execution. WordPress files are stored in /var/www/html. |
| MariaDB | MySQL-compatible database storing all WordPress data. Accessible only by WordPress via the Docker network. Never exposed to outside. |

## Requirements

Before starting the project, make sure these exist on your VM:

### Secret files
```
Inception/secrets/db_root_password.txt
Inception/secrets/db_password.txt
Inception/secrets/wp_admin_password.txt
Inception/secrets/wp_user_password.txt
```

### Environment file
```
Inception/srcs/.env
```

### Domain in /etc/hosts
```
127.0.0.1   muhabin-.42.fr
```

Add it with:
```bash
sudo nano /etc/hosts
```

## Start and Stop the Project

### Start all services
```bash
make
```

### Stop all services
```bash
make stop
```

### Full clean restart (use when changing config or credentials)
```bash
make fclean
make
```

## Access the Website

### WordPress Blog
```
https://muhabin-.42.fr
https://localhost
```

### WordPress Admin Dashboard
```
https://muhabin-.42.fr/wp-admin
https://localhost/wp-admin
```

> Note: The browser will show a security warning because the SSL certificate is self-signed. Click Advanced then Proceed to continue. This is normal for local development.

## Credentials

### Database User (DB_USER)
- Username: from `DB_USER` in `.env`
- Password: in `secrets/db_password.txt`

### Database Root
- Username: `root`
- Password: in `secrets/db_root_password.txt`

### WordPress Admin
- Username: from `WP_ADMIN` in `.env`
- Password: in `secrets/wp_admin_password.txt`

### WordPress Second User
- Username: from `WP_USER` in `.env`
- Password: in `secrets/wp_user_password.txt`

## Check Services are Running

### List all running containers
```bash
docker ps
```

You should see these containers all with status `Up`:
```
nginx
wordpress
mariadb
```

### Monitor logs
```bash
make logs
```

Stop monitoring with `CTRL + C`

### Check a specific container log
```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

## Verify Data Persistence

Data is stored in volumes on the VM at:
```
/home/muhabin-/data/mariadb     ← MariaDB data
/home/muhabin-/data/wordpress   ← WordPress files
```

To test persistence — stop and restart:
```bash
make stop
make start
```

Your site and all data should still be there after restart.

## Troubleshooting

| Problem | Solution |
|---------|---------|
| Cannot connect to site | Make sure you are using `https://` not `http://` |
| Container keeps restarting | Run `docker logs ${container}` to see the error |
| Site loads but wp-admin cannot connect | Run `make fclean` then `make` for fresh install |
| Domain not resolving | Check `/etc/hosts` has `127.0.0.1 muhabin-.42.fr` |
| Changes not taking effect | Run `make fclean` then `make` to rebuild from scratch |
