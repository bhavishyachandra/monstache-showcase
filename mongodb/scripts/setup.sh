#!/bin/bash

mongodb1=`getent hosts ${MONGO1} | awk '{ print $1 }'`

port=${PORT:-27017}

echo "Waiting for startup.."
until mongo --host ${MONGO1}:${port} --eval 'quit(db.runCommand({ ping: 1 }).ok ? 0 : 2)' &>/dev/null; do
  printf '.'
  sleep 1
done

echo "Started.."

echo setup.sh time now: `date +"%T" `
mongo -u ${USER} -p ${PASSWORD} --host ${MONGO1}:${port} <<EOF
   var cfg = {
        "_id": "${RS}",
        "protocolVersion": 1,
        "members": [
            {
                "_id": 0,
                "host": "${MONGO1}:${port}"
            }
        ]
    };
    rs.initiate(cfg, { force: true });
    rs.reconfig(cfg, { force: true });
EOF

mongoimport --authenticationDatabase "admin" --host "mongo" -u "root" -p "password" -d "chicago" -c "crimes" --type "csv" --columnsHaveTypes --parseGrace=skipField --fields="ID.string(),Case Number.string(),Date.date(01/02/2006 03:04:05 PM),Block.string(),IUCR.string(),Primary Type.string(),Description.string(),Location Description.string(),Arrest.boolean(),Domestic.boolean(),Beat.string(),District.string(),Ward.string(),Community Area.string(),FBI Code.string(),X Coordinate.int64(),Y Coordinate.int64(),Year.int32(),Updated On.date(01/02/2006 03:04:05 PM),Latitude.double(),Longitude.double(),Location.auto()" --file="/scripts/data/crimes.csv"
