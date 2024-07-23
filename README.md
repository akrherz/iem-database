# Simple Schema Manager

Eh, I am sure there are much better ways to manage database schema than this,
but alas, here it is.  Fundamentally, we support the following scenarios.

1. A newly setup PostgreSQL database.
2. An upgrade path from previously deployed databases
3. A means to bootstrap a database schema and some initial data to support
CI testing.

The `init` folder contains the initial schema plus incremental changes that
are also tracked in sequential `upgrade` files.  A recent change was to update
the files in `init` with any schema updates made.  The magic happens with a
dedicated table in each database known as `iem_schema_manager_version`,
which tracks a integer value representing the most recent schema update made.

Simply running:

    python schema_manager.py

and things should take care of themselves.  The `bootstrap.sh` exists for
initial deployments, like on CI.

## Bundled test data

To support integration tests, some real data is bundled here for loading into
the database via `store_test_data.py`.  Some terse details on these files in
the `data` folder:

Filename | Contains
--- | ---
afos.db.gz | AFDDMX from 10-16 Jul 2024
asos_alldata.db.gz | ~2020 data for AMW and DSM
hads_alldata.db.gz | 2024 weather variables for EOKI4
