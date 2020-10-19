#!/bin/sh

# Don't allow this command to fail
set -e

echo "HOST IS: $DATABASE_HOSTNAME"
until PGPASSWORD=$DATABASE_PASSWORD psql -h "$DATABASE_HOSTNAME" -U $DATABASE_USERNAME -c '\q'; do
    echo "Postgres is unavailable - sleeping"
    sleep 1
done

echo "Postgres is up - Setting up database"

# Allow this command to fail
set +e
echo "Creating DB. OK to ignore errors about test db."
# https://github.com/rails/rails/issues/27299
bin/rails db:create

# Don't allow any following commands to fail
set -e
echo "Migrating db"
bin/rails db:migrate

echo "Running server"
exec bin/puma -C config/puma.rb config.ru
