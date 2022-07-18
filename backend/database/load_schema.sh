#!/bin/bash

cat ./schema.sql
docker-compose exec plejady_database psql -d plejady -U postgres -c "$(cat ./schema.sql)"
