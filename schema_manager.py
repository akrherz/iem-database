"""
My goal in life is to manage the database schema, so when things change, this
script can handle it all.  I am run like so:

    python schema_manager.py
"""

import os
import sys

import psycopg


def check_management(cursor):
    """Make sure we have management of this database"""
    cursor.execute(
        """
         select * from pg_tables where schemaname = 'public'
         and tablename = 'iem_schema_manager_version'
     """
    )
    if cursor.rowcount == 0:
        cursor.execute(
            """
        CREATE TABLE iem_schema_manager_version
            (version int, updated timestamptz)
        """
        )
        cursor.execute(
            """INSERT into iem_schema_manager_version
        VALUES (-1, now())"""
        )


def run_db(dbname):
    """Lets do an actual database"""
    try:
        dbconn = psycopg.connect(f"postgresql://runner@localhost/{dbname}")
    except psycopg.errors.OperationalError:
        dbconn = psycopg.connect(f"postgresql://iemdb-{dbname}.local/{dbname}")

    cursor = dbconn.cursor()

    check_management(cursor)

    cursor.execute(
        """
        SELECT version, updated from iem_schema_manager_version
    """
    )
    row = cursor.fetchone()
    baseversion = row[0]
    print(
        ("Database: %-15s has revision: %3s (%s)")
        % (dbname, baseversion, row[1].strftime("%Y-%m-%d %H:%M"))
    )

    while True:
        baseversion += 1
        fn = "%s/%s.sql" % (dbname, baseversion)
        if not os.path.isfile(fn):
            break
        print("    -> Attempting schema upgrade #%s ..." % (baseversion,))
        with open(fn, encoding="utf-8") as fh:
            cursor.execute(fh.read())

        cursor.execute(
            """
            UPDATE iem_schema_manager_version
            SET version = %s, updated = now()
            """,
            (baseversion,),
        )

    if len(sys.argv) == 1:
        cursor.close()
        dbconn.commit()
    else:
        print("    + No changes made since argument provided")
    dbconn.close()


def main():
    """Go Main Go"""
    os.chdir("upgrade")
    for dbname in os.listdir("."):
        run_db(dbname)
    print("Done...")


if __name__ == "__main__":
    # main
    main()
