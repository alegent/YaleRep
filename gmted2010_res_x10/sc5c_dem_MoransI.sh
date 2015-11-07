# for list  in  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/sd75_grd_tif/?_?.tif  ; do qsub  -v file=$file  /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc5c_dem_MoransI.sh ; done 

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=0:24:00:00  
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

export INDIR_SD=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/sd75_grd_tif
export OUTGEO=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/moran/tiles
export RAM=/dev/shm

export file=$1

export filename=$(basename $file .tif) 

echo 0 1 2 3 4 5 6 7  | xargs -n 1 -P 8  bash -c $'
tile=$1
gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9 -srcwin $(expr $tile \* 2162) 0 2162 13456  $file $RAM/${filename}_$tile.tif 
' _ 



echo 0 1 2 3 4 5 6 7 | xargs -n 1 -P 8 bash -c $' 
export tile=$1

echo start $RAM/${filename}_$tile.tif 

R --vanilla -q <<EOF

tempfile(tmpdir="/dev/shm/")

library(raster)

filename     = Sys.getenv(\'filename\')
tile         = Sys.getenv(\'tile\')
RAM          = Sys.getenv(\'RAM\')          

rast = raster(print(paste(RAM,"/",filename,"_",tile,".tif",sep="" )))

print(rasterTmpFile())

rasterOptions(tmpdir="/dev/shm/")
options(rasterTmpDir="/dev/shm/")

print(rasterTmpFile())

f1=function(x,na.rm=T) Moran(raster(matrix(x,ncol=4)))

# rasterOptions(progress=\'text\')

aggregate(rast, fact=4, fun=f1 , filename=print(paste(RAM,"/",filename,"_",tile,"_moran.tif",sep="" )) ,  options=c("COMPRESS=LZW") , overwrite=T   )

EOF

' _ 

rm -f $RAM/vrt.vrt

gdalbuildvrt -separate -overwrite $RAM/vrt.vrt $RAM/?_?_?_moran.tif 
gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9     $RAM/vrt.vrt $OUTGEO/$filename.tif 

rm -rf   /dev/shm/*  
rm -rf  /tmp/*     > /dev/null 2>&1

