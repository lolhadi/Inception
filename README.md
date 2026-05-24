*This project has been created as part of the 42 curriculum by muhabin-.*

# Inception

## Description
A system administration project focused on learning and mastering containerization using Docker.

This project requires setting up a functional web application using multiple services — Nginx, WordPress and MariaDB — each running in their own dedicated Docker container inside a Virtual Machine.

## Instructions

### Prerequisites
- Docker
- Docker Compose
- GNU Make
- Linux-based system

### Build and Run

```bash
make
```

## Resources

### Docker
- https://docs.docker.com/get-started/docker-overview/
### Nginx
- https://nginx.org/en/docs/beginners_guide.html
### WordPress
- https://wordpress.org/documentation/article/get-started-with-wordpress/
### MariaDB
- https://mariadb.com/kb/en/documentation/
### WP-CLI
- https://wp-cli.org/

### How AI was used
AI was used to understand the overall architecture of the project before implementation. It helped break the project into smaller, manageable components and clarified the role and interaction of each service.

## Project Description

### Virtual Machine vs Docker

| Virtual Machine | Container |
|-----------------|-----------|
| Isolated operating system | Isolated process environment |
| Pretends to be a whole computer | Pretends to be a server, but is actually just isolated processes |
| Has its own kernel and init system | Shares the host kernel (no separate init system) |
| Heavy (GBs, slower startup) | Lightweight (MBs, fast startup) |

### Secrets vs Environment Variables

| Secrets | Environment Variables |
|---------|----------------------|
| Stored as files inside container | Stored as plain text key-value pairs |
| Used for sensitive values (passwords) | Used for non-sensitive values (ports, names) |
| Read from /run/secrets/ inside container | Directly accessible by the process |
| Never shown in docker inspect output | Visible in docker inspect output |
| Managed securely by Docker | Passed via .env file |

### Docker Network vs Host Network

| Host Network | Docker Network (Bridge) |
|--------------|------------------------|
| Best performance (no network abstraction) | Slight overhead due to network isolation |
| Containers share the host network stack | Each container has its own virtual network |
| No port mapping required | Ports must be explicitly published |
| Port conflicts possible | Multiple containers can use the same internal port |

### Docker Volumes vs Bind Mounts

| Docker Volume | Bind Mount |
|---------------|------------|
| Persistent storage managed by Docker | Direct mapping of a host directory into a container |
| Data survives container restarts and rebuilds | Changes on host immediately visible in container |
| Best suited for production (databases, persistent data) | Best suited for development |
| Controlled by Docker | Controlled by the host filesystem |
