
FROM postgis/postgis:18-3.6-alpine

LABEL org.opencontainers.image.source=https://github.com/akrherz/iem-database
LABEL org.opencontainers.image.description="IEM Database Schema and Test Data"

# With postgresql 18, /var/lib/postgresql is a VOLUME, which we do not want
# as we want to bundle our userland data into this image.
RUN mkdir /opt/pgdata && chown postgres:postgres /opt/pgdata && chmod 700 /opt/pgdata
ENV PGDATA=/opt/pgdata

USER postgres

# Initialize the database and trust all network connections (for now)
RUN initdb -D /opt/pgdata --auth-host=trust --auth-local=trust

# Add pg_hba.conf entry to allow github actions to connect
RUN echo "host all all 172.0.0.0/8 trust" >> /opt/pgdata/pg_hba.conf

# GH286 Trim pg_wal size to 100MB
RUN echo "max_wal_size = 100MB" >> /opt/pgdata/postgresql.conf
