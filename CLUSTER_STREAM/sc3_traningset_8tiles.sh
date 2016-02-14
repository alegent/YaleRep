# qsub -v DIR=normal   /lustre/home/client/fas/sbsc/ga254/scripts/CLUSTER_STREAM/sc3_traningset_8tiles.sh 
# qsub -v DIR=random   /lustre/home/client/fas/sbsc/ga254/scripts/CLUSTER_STREAM/sc3_traningset_8tiles.sh 


# data preparation 

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=8:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /lustre/scratch/client/fas/sbsc/ga254/stdout 
#PBS -e /lustre/scratch/client/fas/sbsc/ga254/stderr

export DIR=random
export MASK=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/mask
export TRAIN=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/training_$DIR
export DIROUT=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM
export RAM=/dev/shm
  
# 39000 13920  
# split the stak in 8 tiles Size is 39000 13920   so 9750  6960

cleanram 

echo 0        0 9750 6960   > $RAM/tiles_xoff_yoff.txt
echo 9750     0 9750 6960  >> $RAM/tiles_xoff_yoff.txt
echo 19500    0 9750 6960  >> $RAM/tiles_xoff_yoff.txt
echo 29250    0 9750 6960  >> $RAM/tiles_xoff_yoff.txt
echo 0     6960 9750 6960  >> $RAM/tiles_xoff_yoff.txt
echo 9750  6960 9750 6960  >> $RAM/tiles_xoff_yoff.txt
echo 19500 6960 9750 6960  >> $RAM/tiles_xoff_yoff.txt
echo 29250 6960 9750 6960  >> $RAM/tiles_xoff_yoff.txt

cat $RAM/tiles_xoff_yoff.txt  | xargs -n 4 -P 8 bash -c $' 

xoff=$1
yoff=$2
xsize=$3
ysize=$4

if [ ! -f $MASK/mask_${1}_${2}.tif ] ; then 

gdal_translate -srcwin  $xoff $yoff $xsize $ysize  -of XYZ   $MASK/mask.tif  $MSK/mask_x${1}_y${2}z.txt 
echo cleaning the  $MSK/mask_x${1}_y${2}.txt 

awk  \'{ if ($3==1) print $1, $2 }\'   $MSK/mask_x${1}_y${2}z.txt       >  $RAM/training_x${1}_y${2}.txt 

cp  $RAM/training_x${1}_y${2}.txt      $TRAIN/training_x${1}_y${2}.txt

gdal_translate -co COMPRESS=LZW -co ZLEVEL=9   -srcwin $xoff $yoff $xsize $ysize  $MASK/mask.tif  $MASK/mask_${1}_${2}.tif

fi 

echo crop the larg stack file
                                                                                                                                       # use the vrt avoiding using the tif
gdal_translate  -ot  Int32  -a_nodata 2147483647   -co  BIGTIFF=YES -co  COMPRESS=LZW -co ZLEVEL=9  -srcwin $xoff $yoff $xsize $ysize  $DIROUT/$DIR/stack.vrt   $DIROUT/$DIR/stack_${1}_${2}.tif

if [ ! -f $RAM/training_x${1}_y${2}.txt  ] ; then echo copy the file ; cp -rf   /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/training_*/training_x${1}_y${2}.txt $RAM ; fi 

oft-extr -o   $RAM/training_x${1}_y${2}_stack.txt $RAM/training_x${1}_y${2}.txt $DIROUT/$DIR/stack_${1}_${2}.tif <<EOF
1
2
EOF

# reduce to integers and take out the space
awk \'{ for (col=1 ; col<=NF ; col++) { printf ("%i ",$col)   } ; printf ("\n",$NF)    }\'     $RAM/training_x${1}_y${2}_stack.txt >  $TRAIN/training_x${1}_y${2}_stack.txt


' _

cleanram 

for CLUST in $(seq 4 100) ; do  qsub -v CLUST=$CLUST,DIR=random  /home/fas/sbsc/ga254/scripts/CLUSTER_STREAM/sc4_clusteringTiles_8tiles.sh  ; done
for CLUST in $(seq 4 100) ; do  qsub -v CLUST=$CLUST,DIR=normal  /home/fas/sbsc/ga254/scripts/CLUSTER_STREAM/sc4_clusteringTiles_8tiles.sh  ; done

