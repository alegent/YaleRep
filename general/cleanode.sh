#! /bin/bash 

# grep the status of the node not down and not down,offline and perform the cleaning 

pbsnodes | grep -e compute-  -e "state = "  | awk '{ if (NF<4) print  }'  | xargs -n 4 -P 1 bash -c $' 

if [  $4 != "down,offline"  ]   ; then 

if [  $4 != "down"  ]   ; then 

echo clean  $1 ;   ssh -x $1  \' find  /dev/shm/ -user $USER  -delete   ;  exit\'  

fi
fi 

' _ 

