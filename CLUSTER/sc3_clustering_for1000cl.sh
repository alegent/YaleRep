#PBS -S /bin/bash 
#PBS -q fas_long
#PBS -l walltime=3:00:00:00  
#PBS -l nodes=1:ppn=5
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr


export MSKDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/mask 
export NORDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/normal
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/cluster

checkjob -v $PBS_JOBID  > /scratch/fas/sbsc/ga254/stdnode/job_start_$PBS_JOBID.txt 

# questo effettua solo il sampling quind per  solo il primo argument e' usato.
# crea il spec_22variables.txt   e lo copia in /dev/shm/spec_22variables.txt

bash   ~/bin/oft-extr4cluster-latlong_om.bash  $NORDIR/stack.tif   /dev/shm/cluster.tif  10  50  $MSKDIR/mask.tif

echo 200 400 600 800 1000 | xargs -n 1  -P 5 bash -c $'   

CLUST=$1

oft-kmeans -um $MSKDIR/mask.tif  -ot UInt16  -oi  /dev/shm/cluster_$CLUST.tif   $NORDIR/stack.tif <<EOF
/dev/shm/spec_22variables.txt
$CLUST
EOF

mv    /dev/shm/cluster_$CLUST.tif    $OUTDIR/cluster_$CLUST.tif 

' _ 

exit 


pkcreatect -min 1 -max $CLUST  >    $OUTDIR/cluster_$CLUST"ct.txt"
pkcreatect -co  COMPRESS=LZW -co ZLEVEL=9  -ct   $OUTDIR/cluster_$CLUST"ct.txt"    -i   /dev/shm/cluster.tif   -o   $OUTDIR/cluster_$CLUST"ct.tif"

rm  /dev/shm/cluster.tif


checkjob -v $PBS_JOBID  > /scratch/fas/sbsc/ga254/stdnode/job_end_$PBS_JOBID.txt 
