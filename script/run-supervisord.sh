#!/bin/sh

echo "DATABASE_URL=${DATABASE_URL}" >> /var/www/app/.env
echo "REDIS_URL=${REDIS_URL}" >> /var/www/app/.env
/usr/bin/supervisord -n
