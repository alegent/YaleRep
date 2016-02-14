# data preparation 

# prepare small tiles o  spead up the computation  39000 13920  ; 39000 / 8  = 4875 ; 13920 / 4 ; 3480
# 8 x 4 = 32 tiles ; 8 x ; 4 y
# for xn in $(seq 0 7 ) ; do  for yn in $(seq 0 3 ) ; do echo $( expr $xn \* 4875  ) $( expr $yn \* 3480 ) 4875    3480   ; done ; done > /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/geo_files/tiles32.txt
# cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/geo_files/
# awk 'NR%8==1 {x="F"++i;}{ print >  "tiles32_"x".txt" }' /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/geo_files/tiles32.txt

# for list in /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/geo_files/tiles32_F?.txt ;  do  qsub  -v list=$list /lustre/home/client/fas/sbsc/ga254/scripts/CLUSTER_STREAM/sc3_traningset.sh ; done

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=4:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /lustre/scratch/client/fas/sbsc/ga254/stdout 
#PBS -e /lustre/scratch/client/fas/sbsc/ga254/stderr

export MSK=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/mask
export TRAI=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/training
export RAM=/dev/shm
export list=$list

cleanram 

cat $list  | xargs -n 4 -P 8 bash -c $' 

xoff=$1
yoff=$2
xsize=$3
ysize=$4

gdal_translate -srcwin  $xoff $yoff $xsize $ysize  -of XYZ   $MSK/mask.tif  $MSK/mask_x${1}_y${2}z.txt 

echo cleaning the  $MSK/mask_x${1}_y${2}.txt 

awk \'{ if ($3==1) print $1, $2 }\'   $MSK/mask_x${1}_y${2}z.txt    >  $RAM/training_x${1}_y${2}.txt 
cp  $RAM/training_x${1}_y${2}.txt   $TRAI/training_x${1}_y${2}.txt 

gdal_translate -co COMPRESS=LZW -co ZLEVEL=9   -srcwin $xoff $yoff $xsize $ysize   /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/normal/stack.tif  /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/normal/stack_${1}_${2}.tif
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9   -srcwin $xoff $yoff $xsize $ysize   /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/mask/mask.tif     /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/mask/mask_${1}_${2}.tif

oft-extr -o   $TRAI/training_x${1}_y${2}_stack.txt    $RAM/training_x${1}_y${2}.txt /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/normal/stack_${1}_${2}.tif   <<EOF
1
2
EOF

' _

cleanram

exit 

