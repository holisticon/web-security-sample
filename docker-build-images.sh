#!/usr/bin/env bash

source ./docker-env.sh

# Remove existing containers
docker-compose stop
docker-compose rm -f
# Recreate containers
docker-compose create
