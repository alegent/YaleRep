# for K in $(seq 1 10 ) do ; qsub  -v K=$K  /home/fas/sbsc/ga254/scripts/CLUSTER_STREAM/sc2_randomsurface.sh ; done 

#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=4:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

export MSKDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/mask
export RAND=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/random 
export RAM=/dev/shm
export K=2

cleanram
# set P to 2 if not you get saturation of the ram 

filen=$(gdalinfo  /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/normal/stack.vrt  | grep tif | wc -l  )

seq 1 $filen  | xargs -n 1 -P 8  bash -c $'  
export LYR=$1
# select the name in the stack 
file=$(gdalinfo /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/normal/stack.vrt  | grep tif | sed \'s=.*/==\' |   awk -v LYR=$LYR  \'{ if ( NR == LYR ) { print }}\' )

minmax=$(gdalinfo -mm /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/normal/$file | grep Computed | awk -F = \'{ print $2  }\' )

if [ ! -f  /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/normal/minmax/$(basename $file .tif).txt  ] ; then  
echo $minmax | awk -F , \'{  print $1 , $2 }\' > /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/normal/minmax/$(basename $file .tif).txt 
fi

export Lmin=$(echo $minmax | awk -F , \'{  print int($1) }\')
export Lmax=$(echo $minmax | awk -F , \'{  print int($2) }\')
 
echo processing random  $LYR with min $Lmin max $Lmax

rm -fr $RAND/grass_locs/loc_random${LYR}_K$K

source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location.sh  $RAND/grass_locs  loc_random${LYR}_K$K   /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/mask/mask.tif 
# setting the mask allow fast computation and smaller raster size 
r.mask raster=mask

echo create  grass rand${LYR} uniform 

r.surf.random out=rand${LYR} min=${Lmin} max=${Lmax}

rm -f $RAND/K$K/rand${LYR}_K$K.tif 
r.out.gdal   nodata=2147483647  -c createopt="COMPRESS=LZW,ZLEVEL=9"  --overwrite   format=GTiff type=Float64  input=rand${LYR} output=$RAND/K$K/rand${LYR}_K$K.tif 

echo setting the mask for $RAND/K$K/rand${LYR}_K$K.tif 

pksetmask -ot Int32 -msknodata 0 -nodata 2147483647 -m $MSKDIR/mask.tif -co COMPRESS=LZW -co ZLEVEL=9 -i $RAND/K$K/rand${LYR}_K$K.tif -o $RAND/K$K/rand${LYR}_K${K}_int_msk.tif
gdal_edit.py -a_srs EPSG:4326 $RAND/K$K/rand${LYR}_K${K}_int_msk.tif

gdalinfo -mm $RAND/K$K/rand${LYR}_K${K}_int_msk.tif  | grep Computed | awk -F = \'{ print $2  }\' |  awk -F , \'{  print $1 , $2  }\'  > $RAND/K$K/minmax/rand${LYR}_K${K}.txt

# rm -r $RAND/grass_locs/loc_random${LYR}_K$K


' _ 

cleanram 

#  in case insert the BIO15 for precip seasonality 
gdalbuildvrt -separate -overwrite  -srcnodata 2147483647   -vrtnodata 2147483647   $RAND/K$K/stack_K$K.vrt $(for seq in $(seq 1 19) ; do echo   $RAND/K$K/rand${seq}_K${K}_int_msk.tif  ; done)

#  computed but not used later. In the sc3 the .vrt is going to be used
gdal_translate  -a_nodata 2147483647   -ot  Int32  -co  BIGTIFF=YES -co  COMPRESS=LZW -co ZLEVEL=9  $RAND/K$K/stack_K${K}.vrt  $RAND/K$K/stack_K${K}.tif


# qsub -v DIR=random   /lustre/home/client/fas/sbsc/ga254/scripts/CLUSTER_STREAM/sc3_traningset_8tiles.sh

# qsub -v DIR=normal   /lustre/home/client/fas/sbsc/ga254/scripts/CLUSTER_STREAM/sc3_traningset_8tiles.sh

checkjob -v $PBS_JOBID  > /scratch/fas/sbsc/ga254/stdnode/sc2_randomsurface.sh.$PBS_JOBID.txt

exit 

# r implementation it works but it is slow
# R --vanilla -q <<EOF
# library(raster)
# LYR  = Sys.getenv(\'LYR\')
# Lmin  = Sys.getenv(\'Lmin\')
# Lmax  = Sys.getenv(\'Lmax\')
# library(raster)
# Lmin 
# Lmax 
# raster=raster(matrix(runif(542880000, max=as.numeric(Lmax) , min=as.numeric(Lmin)), 13920,39000) , xmn=-145, xmx=180, ymn=-56, ymx=60 , crs="+proj=longlat +datum=WGS84 +no_defs")
# writeRaster(raster,filename=paste0("/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/random/rand",LYR,"_float.tif"),options=c("COMPRESS=LZW","ZLEVEL=9","BIGTIFF=YES"),formats=GTiff,overwrite=TRUE)
# EOF







