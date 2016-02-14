# some of them fail in the wall time ...select the one that do not apper in the fas_long

# prepare small tiles o  spead up the computation  39000 13920  ; 39000 / 8  = 4875 ; 13920 / 4 ; 3480 
# 8 x 4 = 32 tiles ; 8 x ; 4 y 
# for xn in $(seq 0 7 ) ; do  for yn in $(seq 0 3 ) ; do echo $( expr $xn \* 4875  ) $( expr $yn \* 3480 ) 4875    3480   ; done ; done > /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/geo_files/tiles32.txt 
# cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/geo_files/
# awk 'NR%8==1 {x="F"++i;}{ print >  "tiles32_"x".txt" }' /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/geo_files/tiles32.txt 

#  for CLUSTER in $(seq 4 100) ; do for list in /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/geo_files/tiles32_F?.txt ; do  qsub -v list=$list,CLUSTER=$CLUSTER   /home/fas/sbsc/ga254/scripts/CLUSTER_STREAM/sc4_clusteringTiles.sh ; done ; done 

#PBS -S /bin/bash 
#PBS -l nodes=1:ppn=8
#PBS -q fas_normal
#PBS -l walltime=4:00:00
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

export list=$list
export CLUSTER=$CLUSTER

echo CLUSTER  $CLUSTER

echo  "CLUSTER $CLUSTER tile $list   /home/fas/sbsc/ga254/scripts/CLUSTER_STREM/sc4_clusteringTiles.sh"    > /scratch/fas/sbsc/ga254/stdnode/sc4_clusteringTiles.sh_start.$PBS_JOBID.txt 
checkjob -v $PBS_JOBID  >> /scratch/fas/sbsc/ga254/stdnode/sc4_clusteringTiles.sh_start.$PBS_JOBID.txt 

export MSKDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/mask
export NORDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/normal 
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/cluster
export TRAIN=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/training
export RAM=/dev/shm

cleanram 

echo sampling the data to speed up the computation. Remove later. 

# done only ones by hand 
# cat $TRAIN/training_x*_y*_stack.txt  |  awk '{if (NR%10==0) print $0}'  >  $TRAIN/training_100_stack.txt

cp  $TRAIN/training_100_stack.txt $RAM

cat $list  | xargs -n 4 -P 8  bash -c $'
# import 4 even if not used
# compute only the file not empty 

max=$(pkstat -mm -i    /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/mask/mask_${1}_${2}.tif | awk \'{  print $4 }\')

if [ $max -eq 1 ]  ; then 

cp $NORDIR/stack_${1}_${2}.tif   $RAM/stack_${1}_${2}.tif
cp $MSKDIR/mask_${1}_${2}.tif    $RAM/mask_${1}_${2}.tif

echo start the cluster $CLUSTER for tiles $RAM/training_x${1}_y${2}_cluster${CLUSTER}.tif

oft-kmeans -um $RAM/mask_${1}_${2}.tif  -ot UInt16  -o $RAM/training_x${1}_y${2}_cluster${CLUSTER}.tif -i  $RAM/stack_${1}_${2}.tif  &> /dev/null  <<EOF
$RAM/training_100_stack.txt
$CLUSTER
EOF

fi 

rm -f  $RAM/stack_${1}_${2}.tif   $RAM/mask_${1}_${2}.tif

' _ 
 
echo  start the marging of 8 tiles in the node

gdalbuildvrt -overwrite -tr 0.0083333333333 0.0083333333333 $RAM/cluster_vrt.vrt     $RAM/training_x*_y*_cluster${CLUSTER}.tif
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9  -ot UInt16    $RAM/cluster_vrt.vrt   $OUTDIR/tiles/cluster_${CLUSTER}_x$(head -1 $list | awk '{ print $1 }')_y$(head -1 $list | awk '{ print $2 }').tif

cleanram 

echo  "CLUSTER $CLUSTER tile $list   /home/fas/sbsc/ga254/scripts/CLUSTER_STREM/sc4_clusteringTiles.sh"    > /scratch/fas/sbsc/ga254/stdnode/sc4_clusteringTiles.sh_end.$PBS_JOBID.txt 
checkjob -v $PBS_JOBID  >> /scratch/fas/sbsc/ga254/stdnode/sc4_clusteringTiles.sh_end.$PBS_JOBID.txt 

exit 


