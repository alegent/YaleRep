#!/bin/bash
#SBATCH -p scavenge
#SBATCH -n 1 -c 8  -N 1  
#SBATCH -t 24:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc08_hysdrosheds_width_aggregation.sh.%J.out
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc08_hysdrosheds_width_aggregation.sh.%J.err
#SBATCH --job-name=sc08_hysdrosheds_width_aggregation.sh

# sbatch /gpfs/home/fas/sbsc/ga254/scripts/NITRO/sc08_hysdrosheds_width_aggregation.sh

export INDIR=/gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/GRWL/GRWL_vector_to_rast
export OUTDIR=/gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NITRO
export RAM=/dev/shm

echo  -145 15  -90 60 a >  $OUTDIR/tile.txt
echo   -90 15    0 60 b >> $OUTDIR/tile.txt
echo     0 15   90 60 c >> $OUTDIR/tile.txt
echo    90 15  180 60 d >> $OUTDIR/tile.txt

echo -145 -56  -90 15 e >> $OUTDIR/tile.txt
echo  -90 -56    0 15 f >> $OUTDIR/tile.txt
echo    0 -56   90 15 g >> $OUTDIR/tile.txt
echo   90 -56  180 15 h >> $OUTDIR/tile.txt

cat $OUTDIR/tile.txt | xargs -n 5  -P 8 bash -c $'

gdalbuildvrt -separate  -overwrite -srcnodata  -9999   -vrtnodata -9999   -te  $1 $2 $3 $4  $RAM/all_tif_$5.vrt   $INDIR/all_tif.vrt 

pkcomposite -co COMPRESS=DEFLATE -co ZLEVEL=9   -srcnodata -9999 -dstnodata -9999 -cr maxallbands  -i  $RAM/all_tif_$5.vrt -o $OUTDIR/GRWL/all_tif_$5.tif 
pkfilter -nodata -9999 -co COMPRESS=DEFLATE -co ZLEVEL=9 -ot Int32 -of GTiff  -dx 30 -dy 30 -f mean  -d 30 -i $OUTDIR/GRWL/all_tif_$5.tif   -o $OUTDIR/GRWL/all_tif1km_$5.tif 

' _ 


gdalbuildvrt -overwrite  -srcnodata  -9999   -vrtnodata -9999   $RAM/all_tif.vrt       $OUTDIR/GRWL/all_tif1km_?.tif 
gdal_translate  -a_nodata -9999 -co COMPRESS=DEFLATE -co ZLEVEL=9  $RAM/all_tif.vrt  $OUTDIR/GRWL/grwl_mean.tif 

rm  $OUTDIR/tile.txt   $RAM/all_tif.vrt   $RAM/all_tif_?.vrt   





