#!/bin/bash
set -e
docker-compose -f docker-compose.yml -f docker-compose.admin.yml run --rm -T node gulp js css hash
