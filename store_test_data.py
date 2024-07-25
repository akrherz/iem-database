"""Provide some basic data to allow for better testing"""

import glob
import os
import subprocess

import psycopg
import requests

NETWORKS = ["IA_ASOS", "IACLIMATE", "IA_COOP", "WFO", "IA_DCP", "ISUSM"]


def do_stations(network):
    """hack"""
    pgconn = psycopg.connect("postgresql://mesonet@localhost/mesosite")
    cursor = pgconn.cursor()
    req = requests.get(
        f"http://mesonet.agron.iastate.edu/geojson/network/{network}.geojson",
        timeout=60,
    )
    data = req.json()
    for feature in data["features"]:
        sid = feature["id"]
        name = feature["properties"]["sname"]
        county = feature["properties"]["county"]
        country = feature["properties"]["country"]
        state = feature["properties"]["state"]
        wfo = feature["properties"]["wfo"]
        climate_site = feature["properties"]["climate_site"]
        tzname = feature["properties"]["tzname"]
        elevation = feature["properties"]["elevation"]
        ugc_zone = feature["properties"]["ugc_zone"]
        ugc_county = feature["properties"]["ugc_county"]
        ncdc81 = feature["properties"]["ncdc81"]
        ncei91 = feature["properties"].get("ncei91")
        (lon, lat) = feature["geometry"]["coordinates"]
        giswkt = f"SRID=4326;POINT({lon} {lat})"
        cursor.execute(
            """
        INSERT into stations(id, name, state, country, elevation, network,
        online, county, plot_name, climate_site, wfo, tzname, metasite,
        ugc_county, ugc_zone, geom, ncdc81, ncei91) VALUES (%s, %s, %s, %s, %s,
        %s, 't', %s, %s, %s, %s, %s, 'f', %s, %s, %s,
        %s, %s)
        """,
            (
                sid,
                name,
                state,
                country,
                elevation,
                network,
                county,
                name,
                climate_site,
                wfo,
                tzname,
                ugc_county,
                ugc_zone,
                giswkt,
                ncdc81,
                ncei91,
            ),
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


def process_dbfiles():
    """Process the DB files."""
    files = glob.glob(os.path.dirname(__file__) + "/data/*.sql*")
    files.sort()
    for fn in files:
        print(fn)
        dbname = os.path.basename(fn).split("_")[0]
        if fn.endswith(".gz"):
            with subprocess.Popen(
                ["zcat", fn], stdout=subprocess.PIPE
            ) as zproc:
                with subprocess.Popen(
                    ["psql", "-v", "ON_ERROR_STOP=1", "-U", "mesonet", dbname],
                    stdin=zproc.stdout,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                ) as proc:
                    proc.wait()
                    print(f"{fn} {proc.stderr.read()} {proc.stdout.read()}")
                    if proc.returncode != 0:
                        raise ValueError("psql returned non-zero!")
            continue
        with subprocess.Popen(
            [
                "psql",
                "-v",
                "ON_ERROR_STOP=1",
                "-U",
                "mesonet",
                "-f",
                fn,
                dbname,
            ],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        ) as proc:
            proc.wait()
            print(f"{fn} {proc.stderr.read()} {proc.stdout.read()}")
            if proc.returncode != 0:
                raise ValueError("psql returned non-zero!")


def main():
    """Workflow"""
    _ = [do_stations(network) for network in NETWORKS]
    process_dbfiles()
    add_webcam()


if __name__ == "__main__":
    main()
