# rasterize poly

# bash /lustre/home/client/fas/sbsc/ga254/scripts/URBAN/sc2_UA_treecovermean.sh

#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=0:04:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /lustre/scratch/client/fas/sbsc/ga254/stdout 
#PBS -e /lustre/scratch/client/fas/sbsc/ga254/stderr

export INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/URBAN/urban_conus/tif
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/URBAN/urban_conus/tif_tree
export TXT=/lustre/scratch/client/fas/sbsc/ga254/dataproces/URBAN/urban_conus/txt_tree
export RAM=/dev/shm

# gdalbuildvrt  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/treecover2000/tif/treecover2000.vrt  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/treecover2000/tif/*.tif
# gdalbuildvrt /lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/datamask/tif/datamask.vrt  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/datamask/tif/*.tif 


ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/URBAN/urban_conus/tif/UA_?????.tif    | xargs -n 1  -P 8  bash -c  $'

file=$1
filename=$(basename $1 .tif)

gdal_translate -projwin  $(getCorners4Gtranslate $file) -co COMPRESS=LZW -co ZLEVEL=9   /lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/treecover2000/tif/treecover2000.vrt  $OUTDIR/${filename}_tree.tif 

oft-stat -i $OUTDIR/${filename}_tree.tif -o $TXT/${filename}_tree_wwater.txt -um $file -nostd   

# crop the data mask and use the value 2 to maks out the water

gdal_translate -projwin  $(getCorners4Gtranslate $file) -co COMPRESS=LZW -co ZLEVEL=9   /lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/datamask/tif/datamask.vrt  $OUTDIR/${filename}_datamask.tif 

pksetmask   -msknodata 2 -nodata 0 -co COMPRESS=LZW -co ZLEVEL=9 -i  $file  -m  $OUTDIR/${filename}_datamask.tif  -o  $INDIR/${filename}_datamask.tif

oft-stat -i $OUTDIR/${filename}_tree.tif -o $TXT/${filename}_tree_nwater.txt -um  $INDIR/${filename}_datamask.tif  -nostd   


' _

exit 

