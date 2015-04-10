
# some of them fail in the wall time ...select the one that do not apper in the fas_long
#  for CLUST in 50 ; do  for DENSITY in  20 ; do  qsub -q fas_devel -l walltime=4:00:00 -v CLUST=$CLUST,DENSITY=$DENSITY /home/fas/sbsc/ga254/scripts/CLUSTER/sc4_clusteringTiles.sh ; done ;  done 
#  for CLUST in 200 500 1000 2000  ; do   for DENSITY in  20 50 ; do   qsub -q fas_normal  -l  walltime=1:00:00:00  -v CLUST=$CLUST,DENSITY=$DENSITY /home/fas/sbsc/ga254/scripts/CLUSTER/sc4_clusteringTiles.sh ; done ;  done 

#  run it in fas_long
#  for CLUST in 500 1000 2000 5000 10000  ; do   for DENSITY in  10 ; do   qsub -q fas_long -l     walltime=3:00:00:00     -v CLUST=$CLUST,DENSITY=$DENSITY /home/fas/sbsc/ga254/scripts/CLUSTER/sc4_clusteringTiles.sh ; done ;  done
#  for CLUST in 5000 10000  ; do   for DENSITY in  20 ; do   qsub -q fas_long -l     walltime=3:00:00:00     -v CLUST=$CLUST,DENSITY=$DENSITY /home/fas/sbsc/ga254/scripts/CLUSTER/sc4_clusteringTiles.sh ; done ;  done 
#  for CLUST in 10000  ; do   for DENSITY in  50 ; do   qsub -q fas_long -l     walltime=3:00:00:00     -v CLUST=$CLUST,DENSITY=$DENSITY /home/fas/sbsc/ga254/scripts/CLUSTER/sc4_clusteringTiles.sh ; done ;  done 


#PBS -S /bin/bash 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

echo  "CLUST $CLUST DENSITY $DENSITY /home/fas/sbsc/ga254/scripts/CLUSTER/sc4_clusteringTiles.sh"    > /scratch/fas/sbsc/ga254/stdnode/job_start_$PBS_JOBID.txt 
checkjob -v $PBS_JOBID  >> /scratch/fas/sbsc/ga254/stdnode/job_start_$PBS_JOBID.txt 



export MSKDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/mask 
export NORDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/normal
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/cluster
export TRAIN=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER/training
export RAM=/dev/shm

export CLUST=$CLUST
export DENSITY=$DENSITY

echo  cluster $CLUST sampling evry $DENSITY
# split the stak in 8 tiles Size is 43200, 16800  so 10800  8400 

echo 0        0   > $RAM/tiles_xoff_yoff.txt
echo 10800    0   >> $RAM/tiles_xoff_yoff.txt
echo 21600    0   >> $RAM/tiles_xoff_yoff.txt
echo 32400    0   >> $RAM/tiles_xoff_yoff.txt
echo 0     8400   >> $RAM/tiles_xoff_yoff.txt
echo 10800 8400   >> $RAM/tiles_xoff_yoff.txt
echo 21600 8400   >> $RAM/tiles_xoff_yoff.txt
echo 32400 8400   >> $RAM/tiles_xoff_yoff.txt

echo start the cluster 

cat $RAM/tiles_xoff_yoff.txt  | xargs -n 2 -P 8  bash -c $'

cat  $TRAIN/training_x*_y*_stack_evry$DENSITY.txt > $RAM/training_stack_evry$DENSITY.txt
cp $NORDIR/stack_${1}_${2}.tif   $RAM/stack_${1}_${2}.tif
cp $MSKDIR/mask_greenland_${1}_${2}.tif  $RAM/mask_greenland_${1}_${2}.tif

oft-kmeans -um $RAM/mask_greenland_${1}_${2}.tif  -ot UInt16  -o $RAM/training_x${1}_y${2}_cluster${CLUST}_evry${DENSITY}_tmp.tif -i  $RAM/stack_${1}_${2}.tif  << EOF
$RAM/training_stack_evry$DENSITY.txt
$CLUST
EOF

' _ 

echo "############################################################### start the marging ######################################"

gdalbuildvrt -overwrite -tr 0.0083333333333 0.0083333333333 $RAM/cluster_vrt.vrt     $RAM/training_x*_y*_cluster${CLUST}_evry${DENSITY}_tmp.tif

gdal_translate -co COMPRESS=LZW -co ZLEVEL=9  -ot UInt16 $RAM/cluster_vrt.vrt   $OUTDIR/cluster${CLUST}_evry${DENSITY}p.tif


rm -f  $RAM/training_x*_y*_cluster*_evry*_tmp.tif  $RAM/mask_greenland_*_*.tif   $RAM/stack_*_*.tif    $RAM/cluster_vrt.vrt  $RAM/tiles_xoff_yoff.txt  $RAM/training_stack_evry$DENSITY.txt 

echo  "CLUST $CLUST DENSITY $DENSITY /home/fas/sbsc/ga254/scripts/CLUSTER/sc4_clusteringTiles.sh"    >  /scratch/fas/sbsc/ga254/stdnode/job_end_$PBS_JOBID.txt 
checkjob -v $PBS_JOBID  >> /scratch/fas/sbsc/ga254/stdnode/job_end_$PBS_JOBID.txt 
