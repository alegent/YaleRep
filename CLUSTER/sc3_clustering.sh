#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=0:24:00:00  
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr


export MSKDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/mask 
export NORDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/normal
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/cluster


CLUST=1000

checkjob -v $PBS_JOBID  > /scratch/fas/sbsc/ga254/stdnode/job_start_$PBS_JOBID.txt 

oft-cluster-latlong_om.bash   $NORDIR/stack.tif   /dev/shm/cluster.tif  $CLUST  50  $MSKDIR/mask.tif

exit 

pkcreatect -min 1 -max $CLUST  >    $OUTDIR/cluster_$CLUST"ct.txt"
pkcreatect -co  COMPRESS=LZW -co ZLEVEL=9  -ct   $OUTDIR/cluster_$CLUST"ct.txt"    -i   /dev/shm/cluster.tif   -o   $OUTDIR/cluster_$CLUST"ct.tif"

rm  /dev/shm/cluster.tif

checkjob -v $PBS_JOBID  > /scratch/fas/sbsc/ga254/stdnode/job_end_$PBS_JOBID.txt 
