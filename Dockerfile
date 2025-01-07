
FROM postgis/postgis:17-3.5-alpine

# cull the default database
RUN rm -rf /var/lib/postgresql/data

# The base image defines a VOLUME for /var/lib/postgresql/data
ENV PGDATA=/var/lib/postgresql/17/data

USER postgres

RUN initdb -D /var/lib/postgresql/17/data

