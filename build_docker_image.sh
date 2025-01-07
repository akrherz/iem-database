set -e -x

# Here lies how we build a docker image that contains the IEM testing database
docker build -t iem_database -f Dockerfile .

# Start the container to load schema, but no data yet
docker rm -f iem_database || true
docker run --name iem_database -p 5432:5432 -d iem_database

# Ensure PostgreSQL is fully initialized and listening on port 5432
until pg_isready -h localhost -U postgres; do
  echo 'Waiting for PostgreSQL to initialize...'
  sleep 2
done

# Create a runner superuser, unsure if we need this...
psql -c 'CREATE ROLE runner SUPERUSER LOGIN CREATEDB;' -h localhost -U postgres

sh bootstrap.sh

# Now we need to stop and save off this container as an image without test data
# 10 seconds is too short and may corrupt the database
docker stop -t 120 iem_database

# Commit the container to an image, this is the base image as it has
# everything we want.
docker commit iem_database iem_database

# Tag this image for uploading to dockerhub
docker tag iem_database akrherz/iem_database:no_test_data

# Start the container to load test data
docker rm -f iem_database || true
docker run --name iem_database -p 5432:5432 -d iem_database

# Ensure PostgreSQL is fully initialized and listening on port 5432
until pg_isready -h localhost -U postgres; do
  echo 'Waiting for PostgreSQL to initialize...'
  sleep 2
done

psql -f data/postgis/cwsu.db -U mesonet -h localhost postgis
python3 schema_manager.py
python3 store_test_data.py
vacuumdb -f -a -j 4 -U postgres -h localhost

# Stop the container, again be careful to wait
docker stop -t 120 iem_database

# Commit the container to an image
docker commit iem_database akrherz/iem_database:test_data
