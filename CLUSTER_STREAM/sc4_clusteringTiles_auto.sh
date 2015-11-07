
# some of them fail in the wall time ...select the one that do not apper in the fas_long

#  qsub -q fas_normal -l walltime=24:00:00 /home/fas/sbsc/ga254/scripts/CLUSTER_STREAM/sc4_clusteringTiles_auto.sh 

#PBS -S /bin/bash 
#PBS -l nodes=1:ppn=8
#PBS -l mem=34gb
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr



echo  "CLUST /home/fas/sbsc/ga254/scripts/CLUSTER_STREM/sc4_clusteringTiles_auto.sh"    > /scratch/fas/sbsc/ga254/stdnode/job_start_$PBS_JOBID.txt 
checkjob -v $PBS_JOBID  >> /scratch/fas/sbsc/ga254/stdnode/job_start_$PBS_JOBID.txt 


export MSKDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/mask
export NORDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/normal 
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/cluster
export TRAIN=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/training
export RAM=/dev/shm

rm  -fr /dev/shm/*


# split the stak in 8 tiles Size is 39000 13920   so 9750  6960

echo 0        0 9750 6960   > $RAM/tiles_xoff_yoff.txt
echo 9750     0 9750 6960  >> $RAM/tiles_xoff_yoff.txt
echo 19500    0 9750 6960  >> $RAM/tiles_xoff_yoff.txt
echo 29250    0 9750 6960  >> $RAM/tiles_xoff_yoff.txt
echo 0     6960 9750 6960  >> $RAM/tiles_xoff_yoff.txt
echo 9750  6960 9750 6960  >> $RAM/tiles_xoff_yoff.txt
echo 19500 6960 9750 6960  >> $RAM/tiles_xoff_yoff.txt
echo 29250 6960 9750 6960  >> $RAM/tiles_xoff_yoff.txt

echo sampling the data

cat $TRAIN/training_x*_y*_stack.txt  |  awk '{if (NR%10==0) print $0}'  >  $TRAIN/training_10_stack.txt

echo training ready  $TRAIN/training_10_stack.txt 

cp  $TRAIN/training_10_stack.txt $RAM


cat $RAM/tiles_xoff_yoff.txt  | xargs -n 2 -P 4  bash -c $'

cp $NORDIR/stack_${1}_${2}.tif   $RAM/stack_${1}_${2}.tif
cp $MSKDIR/mask_${1}_${2}.tif    $RAM/mask_${1}_${2}.tif

echo start the cluster 

oft-kmeans  -um $RAM/mask_${1}_${2}.tif  -ot UInt16  -o $RAM/training_x${1}_y${2}_cluster_auto.tif -i  $RAM/stack_${1}_${2}.tif  -auto << EOF
$RAM/training_10_stack.txt
EOF

# rm $RAM/stack_${1}_${2}.tif      $RAM/mask_${1}_${2}.tif

' _ 


 
echo "############################################################### start the marging ######################################"

gdalbuildvrt -overwrite -tr 0.0083333333333 0.0083333333333 $RAM/cluster_vrt.vrt     $RAM/training_x*_y*_cluster_auto.tif

gdal_translate -co COMPRESS=LZW -co ZLEVEL=9  -ot UInt16 $RAM/cluster_vrt.vrt   $OUTDIR/cluster_auto.tif

CLUST=$( pkstat -max -i  $OUTDIR/cluster_auto.tif | awk '{  print $2 }' ) 

echo 0 255 255 255  >   /dev/shm/color.txt ; 
for n in $( seq 1 ${CLUST}  ) ; do echo -n $n $[ RANDOM % 256 ]" " ; echo -n  $[ RANDOM % 256 ]" "  ; echo -n  $[ RANDOM % 256 ]" " ; echo ""  ;  done  >>   /dev/shm/color.txt

pkcreatect   -co COMPRESS=LZW -co ZLEVEL=9   -ct   /dev/shm/color.txt   -i   $OUTDIR/cluster_auto.tif -o  $OUTDIR/cluster_auto${CLUST}_ct.tif

rm -f    $RAM/mask_*_*.tif   $RAM/stack_*_*.tif    $RAM/cluster_vrt.vrt  $RAM/tiles*.txt  $RAM/training*.txt    /dev/shm/color.txt 

echo  "CLUST auto   /home/fas/sbsc/ga254/scripts/CLUSTER/sc4_clusteringTiles_auto.sh"    >  /scratch/fas/sbsc/ga254/stdnode/job_end_$PBS_JOBID.txt 
checkjob -v $PBS_JOBID  >> /scratch/fas/sbsc/ga254/stdnode/job_end_$PBS_JOBID.txt 
