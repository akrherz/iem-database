
FROM postgis/postgis:17-3.5-alpine

LABEL org.opencontainers.image.source https://github.com/akrherz/iem-database
LABEL org.opencontainers.image.description IEM Database Schema and Test Data

# cull the default database
RUN rm -rf /var/lib/postgresql/data

# The base image defines a VOLUME for /var/lib/postgresql/data
ENV PGDATA=/var/lib/postgresql/17/data

USER postgres

# Initialize the database and trust all network connections (for now)
RUN initdb -D /var/lib/postgresql/17/data --auth-host=trust --auth-local=trust

# Add pg_hba.conf entry to allow github actions to connect
RUN echo "host all all 172.0.0.0/8 trust" >> /var/lib/postgresql/17/data/pg_hba.conf

# GH286 Trim pg_wal size to 100MB
RUN echo "max_wal_size = 100MB" >> /var/lib/postgresql/17/data/postgresql.conf
