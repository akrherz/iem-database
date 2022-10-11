"""Provide some basic data to allow for better testing"""
import requests

try:
    # Lovely hack here to use my custom connection when possible
    from pyiem.util import get_dbconn
except ImportError:
    from psycopg2 import connect as get_dbconn

NETWORKS = ["IA_ASOS", "AWOS", "IACLIMATE", "IA_COOP"]


def fake_hads_wind():
    """Create some faked wind data for pyiem windrose utils exercising."""
    pgconn = get_dbconn(database="hads", user="mesonet")
    cursor = pgconn.cursor()
    cursor.execute(
        """
        insert into alldata(station, valid, sknt, drct)
        select 'XXXX',
        generate_series('2019-12-20 12:00+00', '2021-01-05 12:00',
            '1 hour'::interval),
        generate_series(1, 9175) / 500. as sknt, -- 18.35 max
        generate_series(1, 9175) / 26. as drct -- 352.9 max
        """
    )
    cursor.close()
    pgconn.commit()
    pgconn.close()


def fake_asos(station):
    """hack"""
    pgconn = get_dbconn(database="asos", user="mesonet")
    cursor = pgconn.cursor()
    for year in range(1995, 1997):
        cursor.execute(
            """
        insert into t%s(station, valid, tmpf, dwpf) SELECT '%s',
        generate_series('%s-01-02 00:00'::timestamp,
        '%s-12-02 00:00'::timestamp, '1 hour'::interval),
        random() * 100., random() * 100.
        """
            % (year, station, year, year)
        )
    cursor.close()
    pgconn.commit()
    pgconn.close()


def do_stations(network):
    """hack"""
    pgconn = get_dbconn(database="mesosite", user="mesonet")
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
        cursor.execute(
            """
        INSERT into stations(id, name, state, country, elevation, network,
        online, county, plot_name, climate_site, wfo, tzname, metasite,
        ugc_county, ugc_zone, geom, ncdc81, ncei91) VALUES (%s, %s, %s, %s, %s,
        %s, 't', %s, %s, %s, %s, %s, 'f', %s, %s, 'SRID=4326;POINT(%s %s)',
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
                lon,
                lat,
                ncdc81,
                ncei91,
            ),
        )
    cursor.close()
    pgconn.commit()
    pgconn.close()


def main():
    """Workflow"""
    _ = [do_stations(network) for network in NETWORKS]
    _ = [fake_asos(station) for station in ["AMW", "DSM"]]
    fake_hads_wind()


if __name__ == "__main__":
    main()
