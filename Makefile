NAME = inception

DOCKER_COMPOSE_FILE = ./srcs/docker-compose.yml

LOGIN = muhabin-

all: build start

# ! CREATE FOLDER (VM MODE)
# create folders required by subject
create_folder:
	mkdir -p /home/$(LOGIN)/data/mariadb
	mkdir -p /home/$(LOGIN)/data/wordpress

# build images aka compile
# -f: explicitly tells where the file is
build: create_folder
	@docker compose -f $(DOCKER_COMPOSE_FILE) build

# up: creates and starts the containers defined in your compose file
# -d: tells Docker start the containers in the background instead on the terminal
start:
	@docker compose -f $(DOCKER_COMPOSE_FILE) up -d

# stop the running containers without removing them
stop:
	@docker compose -f $(DOCKER_COMPOSE_FILE) stop

# shows the stdout/stderr output of your containers
logs:
	@docker compose -f $(DOCKER_COMPOSE_FILE) logs

# down: shut down the container and remove them
clean:
	@docker compose -f $(DOCKER_COMPOSE_FILE) down

# --rmi all: Removes all images used by the services in docker-compose.yml
# --remove-orphans: Removes containers for services not defined in the current yaml file
# -v: Removes named volumes declared in the volumes section
fclean:
	@sudo rm -rf /home/$(LOGIN)/data/mariadb
	@sudo rm -rf /home/$(LOGIN)/data/wordpress
	@docker compose -f $(DOCKER_COMPOSE_FILE) down --rmi all --remove-orphans -v

re: fclean all

.PHONY: all build start logs stop clean fclean re
