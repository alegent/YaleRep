# qsub   /home/fas/sbsc/ga254/scripts/CLUSTER_STREAM/sc2_randomsurface.sh

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=16:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr



export MSKDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/mask
export   RAND=/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/random 
export    RAM=/dev/shm


cleanram
# set P to 2 if not you get saturation of the ram 

filen=$(gdalinfo  /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/normal/stack.vrt  | grep tif | wc -l  )

seq 1 $filen | xargs -n 1 -P 1  bash -c $'  

export LYR=$1

file=$(gdalinfo  /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/normal/stack.vrt  | grep tif | sed 's=.*/==' |   awk -v LYR=$LYR  '{ if ( NR == LYR ) {  print   }  }' )

minmax=$(gdalinfo -mm /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/normal/$file | grep Computed | awk -F = \'{ print $2  }\' )
export Lmin=$(echo $minmax | awk -F , \'{  print int($1) }\')
export Lmax=$(echo $minmax | awk -F , \'{  print int($2) }\')
 
echo processing random  $LYR with min $Lmin max $Lmax

R --vanilla -q <<EOF

library(raster)

LYR  = Sys.getenv(\'LYR\')
Lmin  = Sys.getenv(\'Lmin\')
Lmax  = Sys.getenv(\'Lmax\')

library(raster)

Lmin 
Lmax 


raster=raster(matrix(runif(542880000, max=as.numeric(Lmax) , min=as.numeric(Lmin)), 13920,39000) , xmn=-145, xmx=180, ymn=-56, ymx=60 , crs="+proj=longlat +datum=WGS84 +no_defs")

writeRaster(raster,filename=paste0("/lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/random/rand",LYR,"_float.tif"),options=c("COMPRESS=LZW","ZLEVEL=9","BIGTIFF=YES"),formats=GTiff,overwrite=TRUE)

EOF

pksetmask  -ot  Int32  -msknodata 0 -nodata  2147483647  -m   $MSKDIR/mask.tif  -co  COMPRESS=LZW -co ZLEVEL=9  -i $RAND/rand${LYR}_float.tif   -o  $RAND/rand${LYR}_int_msk.tif
gdal_edit.py    -a_srs EPSG:4326  $RAND/rand${LYR}_int_msk.tif 

' _ 

#  in case insert the BIO15 for precip seasonality 

gdalbuildvrt -separate -overwrite  -srcnodata 2147483647   -vrtnodata 2147483647   $RAND/stack.vrt $(for seq in $(seq 1 19) ; do echo   $RAND/rand${seq}_int_msk.tif  ; done)

# computed but not used later. In the sc3 the .vrt is going to be used
gdal_translate  -a_nodata 2147483647   -ot  Int32  -co  BIGTIFF=YES -co  COMPRESS=LZW -co ZLEVEL=9  $RAND/stack.vrt  $RAND/stack.tif

checkjob -v $PBS_JOBID  > /scratch/fas/sbsc/ga254/stdnode/sc2_randomsurface.sh.$PBS_JOBID.txt

cleanram 

qsub -v DIR=random   /lustre/home/client/fas/sbsc/ga254/scripts/CLUSTER_STREAM/sc3_traningset_8tiles.sh 

exit 

# abbandonato non si capisce bene come si fa
# source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location.sh  $RAM  loc_random   /lustre/scratch/client/fas/sbsc/ga254/dataproces/CLUSTER_STREAM/mask/mask.tif 
# r.random.surface  high=2    output=random1  distance=0  exponent=1  flat=0   --overwrite 
# r.out.gdal -c     createopt="COMPRESS=LZW,ZLEVEL=9" format=GTiff      input=random1      output=$RAND/random1.tif 

