"""Provide some basic data to allow for better testing"""

import glob
import os
import subprocess
import sys

import psycopg
import requests

NETWORKS = [
    "IA_RWIS",
    "IA_ASOS",
    "IACLIMATE",
    "IA_COOP",
    "IA_COCORAHS",
    "WFO",
    "IA_DCP",
    "ISUSM",
    "ISUAG",
    "TALLTOWERS",
    "RAOB",
    "NWSCLI",
    "NEXRAD",
]


def _s(val):
    if val is None:
        return None
    return val[:10]


def do_stations(network: str):
    """hack"""
    req = requests.get(
        f"http://mesonet.agron.iastate.edu/api/1/network/{network}.json",
        timeout=60,
    )
    data = req.json()
    for dbname in "mesosite iem coop".split():
        pgconn = psycopg.connect(
            f"postgresql://mesonet@localhost/{dbname}?gssencmode=disable"
        )
        cursor = pgconn.cursor()
        for entry in data["data"]:
            cursor.execute(
                """
            INSERT into stations(iemid, id, name, state, country, elevation,
            network,online, county, plot_name, climate_site, wfo, tzname,
            metasite, ugc_county, ugc_zone, ncdc81, ncei91, archive_begin,
            archive_end, geom, remote_id) VALUES (%s, %s, %s, %s, %s, %s,
            %s, 't', %s, %s, %s, %s, %s, 'f', %s, %s, %s,
            %s, %s, %s, ST_Point(%s, %s, 4326), %s)
            """,
                (
                    entry["iemid"],
                    entry["id"],
                    entry["name"],
                    entry["state"],
                    entry["country"],
                    entry["elevation"],
                    network,
                    entry["county"],
                    entry["name"],
                    entry["climate_site"],
                    entry["wfo"],
                    entry["tzname"],
                    entry["ugc_county"],
                    entry["ugc_zone"],
                    entry["ncdc81"],
                    entry["ncei91"],
                    _s(entry["archive_begin"]),
                    _s(entry["archive_end"]),
                    entry["longitude"],
                    entry["latitude"],
                    entry["remote_id"],
                ),
            )

        # We have messed use the stations_iemid_seq at this point, so
        # we need to fix it
        cursor.execute(
            "SELECT setval('stations_iemid_seq', max(iemid)) from stations"
        )

        cursor.close()
        pgconn.commit()
        pgconn.close()


def add_webcam():
    """Add a webcam"""
    pgconn = psycopg.connect("postgresql://mesonet@localhost/mesosite")
    cursor = pgconn.cursor()
    cursor.execute(
        """
        INSERT into webcams(id, name, network, online)
        VALUES ('KCCI-027', 'ISU Ag Farm', 'KCCI', 't')
    """
    )
    cursor.close()
    pgconn.commit()
    pgconn.close()


def process_dbfiles(psql):
    """Process the DB files."""
    files = glob.glob(os.path.dirname(__file__) + "/data/*.sql*")
    files.sort()
    args = ["-v", "ON_ERROR_STOP=1", "-U", "mesonet", "-h", "localhost"]
    for fn in files:
        # Le Sigh for iemre_china and iemre_europe
        sep = "__" if fn.find("__") > 0 else "_"
        dbname = os.path.basename(fn).split(sep)[0]
        if fn.endswith(".gz"):
            with subprocess.Popen(
                ["zcat", fn], stdout=subprocess.PIPE
            ) as zproc:
                with subprocess.Popen(
                    [psql, *args, dbname],
                    stdin=zproc.stdout,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                ) as proc:
                    proc.wait()
                    print(f"{fn} {proc.stderr.read()} {proc.stdout.read()}")
                    if proc.returncode != 0:
                        raise ValueError(f"{psql} returned non-zero!")
            continue
        with subprocess.Popen(
            [psql, *args, "-f", fn, dbname],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        ) as proc:
            proc.wait()
            print(f"{fn} {proc.stderr.read()} {proc.stdout.read()}")
            if proc.returncode != 0:
                raise ValueError(f"{psql} returned non-zero!")


def main(argv):
    """Workflow"""
    _ = [do_stations(network) for network in NETWORKS]
    psql = "psql" if len(argv) == 1 else argv[1]
    process_dbfiles(psql)
    add_webcam()


if __name__ == "__main__":
    main(sys.argv)
