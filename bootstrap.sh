# setup databases
# we want this script to exit 2 so that travis will report any failures

for myuser in nobody apache mesonet ldm apiuser \
tt_web tt_admin tt_script
do
/usr/bin/psql -v "ON_ERROR_STOP=1" -c "create user $myuser;" -h localhost -U postgres
done

for db in afos mesosite postgis snet talltowers \
asos asos1min hads hml mos rwis squaw \
awos iem   other      scan     wepp \
coop isuag portfolio  smos     iemre radar nldn sustainablecorn td idep
do
/usr/bin/psql -v "ON_ERROR_STOP=1" -c "create database $db;" -h localhost -U postgres || exit 2
/usr/bin/psql -v "ON_ERROR_STOP=1" -f functions.sql -h localhost -U postgres -q $db || exit 2
/usr/bin/psql -v "ON_ERROR_STOP=1" -f init/${db}.sql -h localhost -U postgres -q $db || exit 2
done
