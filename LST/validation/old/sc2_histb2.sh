
# for YEAR  in $(seq 2002 2014) ; do qsub -v YEAR=$YEAR,SENS=$SENS  /u/gamatull/scripts/LST/sc2_histb2.sh ; done

#PBS -S /bin/bash
#PBS -q normal
#PBS -l select=1:ncpus=1
#PBS -l walltime=1:00:00
#PBS -V
#PBS -o   /nobackup/gamatull/stdout
#PBS -e   /nobackup/gamatull/stderr



export  YEAR=$YEAR
export  SENS=$SENS

export INSENS=/nobackupp8/gamatull/dataproces/LST/${SENS}11A2


echo start the year  for $YEAR  sc2_histb2.sh 


ls $INSENS/$YEAR/*.tif  | xargs -n 1 -P 30 bash -c $'
file=$1
pkinfo -hist -b 1  -i  $file  | awk \'{ if($2!=0) print $1 }\'  

' _  |  sort | uniq    >  $INSENS/$YEAR/hist_b2.txt 



# when all finish 
#  cat  /nobackupp8/gamatull/dataproces/LST/${SENS}11A2*/hist*  | sort -g  | uniq  > /nobackupp8/gamatull/dataproces/LST/${SENS}11A2/hist_b2.txt 