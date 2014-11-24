#!  /bin/bash

rm -f  /home/fas/sbsc/ga254/node.txt
qsub    /home/fas/sbsc/ga254/scripts/general/get_node.sh

while [ ! -f /home/fas/sbsc/ga254/node.txt ]
do
    sleep 2
done

ssh -X  $( cat /home/fas/sbsc/ga254/node.txt )

rm  -f /home/fas/sbsc/ga254/node.txt 