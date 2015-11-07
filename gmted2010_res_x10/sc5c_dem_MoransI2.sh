# for file   in  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/sd75_grd_tif/?_?.tif  ; do qsub  -v file=$file  /lustre/home/client/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc5c_dem_MoransI2.sh ; done 

#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=0:24:00:00  
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

export INDIR_SD=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/sd75_grd_tif
export OUTGEO=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/moran/tiles
export RAM=/dev/shm
export file=$file
export filename=$(basename $file .tif) 


rm -rf  /dev/shm/*



for tilex in 0 1 2 3 ; do 

export tilex=$tilex

echo 0 1 2 3 | xargs -n 1 -P 8  bash -c $'
tiley=$1
gdal_translate -co COMPRESS=LZW -co ZLEVEL=9 -srcwin $(expr $tilex \* 4324) $(expr $tiley \* 3364) 4324 3364 $file $RAM/${filename}_$tilex$tiley.tif 
pkinfo -nodata -32768   -mm -i  /dev/shm/${filename}_$tilex$tiley.tif   > /dev/shm/${filename}_$tilex$tiley.txt
min=$( awk \'{  print $2 }\' /dev/shm/${filename}_$tilex$tiley.txt)
max=$( awk \'{  print $4 }\' /dev/shm/${filename}_$tilex$tiley.txt)
if [[ $min -eq 0  &&  $max -eq 0 ]] ; then rm $RAM/${filename}_$tilex$tiley.tif  ; fi
rm   /dev/shm/${filename}_$tilex$tiley.txt
' _ 

done

ls $RAM/?_?_??.tif | xargs -n 1 -P 8 bash -c $' 

export filename2=$(basename $1 .tif)

R --vanilla -q <<EOF

rmr=function(x){
## function to truly delete raster and temporary files associated with them
if(class(x)=="RasterLayer"&grepl("^/tmp",x@file@name)&fromDisk(x)==T){
file.remove(x@file@name,sub("grd","gri",x@file@name))
rm(x)
}
}

tempfile(tmpdir="/dev/shm/")

library(raster)

filename2     = Sys.getenv(\'filename2\')
RAM          = Sys.getenv(\'RAM\')          

rast = raster(print(paste(RAM,"/",filename2,".tif",sep="" )))

rasterOptions(tmpdir="/dev/shm/")
options(rasterTmpDir="/dev/shm/")

print(paste("processing moran s I for file",RAM,"/",filename2,"_moran.tif",sep="" ))

f1=function(x,na.rm=T) Moran(raster(matrix(x,ncol=4)))

aggregate(rast, fact=4, fun=f1 , filename=print(paste(RAM,"/",filename2,"_moran.tif",sep="" )) ,  options=c("COMPRESS=LZW") , overwrite=T   )

print(paste("end of processing moran s I for file",RAM,"/",filename2,"_moran.tif",sep="" ))

EOF

' _ 

rm -f $RAM/vrt.vrt

gdalbuildvrt -overwrite $RAM/vrt.vrt $RAM/?_?_??_moran.tif 
gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9     $RAM/vrt.vrt $OUTGEO/$filename.tif 

rm -rf   /dev/shm/*  
rm -rf  /tmp/*     > /dev/null 2>&1

exit 

