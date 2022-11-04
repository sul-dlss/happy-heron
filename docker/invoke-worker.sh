#!/bin/sh

# Don't allow this command to fail
set -e

echo "HOST IS: $DATABASE_HOSTNAME"
until PGPASSWORD=$DATABASE_PASSWORD psql -h "$DATABASE_HOSTNAME" -U $DATABASE_USERNAME -c '\q'; do
    echo "Postgres is unavailable - sleeping"
    sleep 1
done
echo "Postgres is up"

until redis-cli -u $REDIS_URL ping | grep -q PONG; do
    echo "Redis is unavailable at $REDIS_URL - sleeping"
    sleep 1
done
echo "Redis is up at $REDIS_URL"

# Don't allow any following commands to fail
set -e
echo "Running workers"
exec bin/bundle exec sidekiq
