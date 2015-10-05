#/bin/bash

bulklines="./bulkinsert/bulk_lines.sh"
bulklinestation="./bulkinsert/bulk_linestation.sh"
bulkstation="./bulkinsert/bulk_station.sh"

if [ -f $bulklines ];
then 
#echo "Find File "
bash $bulklines
fi



if [ -f $bulklinestation ];
then 
#echo "Find File "
bash $bulklinestation
fi


if [ -f $bulkstation ];
then 
#echo "Find File "
bash $bulkstation
fi
