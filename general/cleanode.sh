#! /bin/bash 

# these node are not working -v compute-37-11   -v compute-32-8
 
pbsnodes  | grep compute | awk '{ if(NF==1) print  }' | grep -v compute-37-11 | grep  -v compute-32-8 | grep -v compute-74-15  |  grep -v compute-68-11  |  grep -v compute-33-12  | xargs -n 1 -P 4 bash -c $' echo $1 ;   ssh -x $1  \' find  /dev/shm/ -user ga254 -delete   ;  exit\'  ' _ 