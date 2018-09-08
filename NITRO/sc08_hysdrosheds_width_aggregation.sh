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

echo  -145 15  -125 60 an >  $OUTDIR/tile.txt
echo  -125 15  -105 60 bn >> $OUTDIR/tile.txt
echo  -105 15   -85 60 cn >> $OUTDIR/tile.txt
echo   -85 15   -65 60 dn >> $OUTDIR/tile.txt
echo   -65 15   -45 60 en >> $OUTDIR/tile.txt
echo   -45 15   -25 60 fn >> $OUTDIR/tile.txt
echo   -25 15    -5 60 gn >> $OUTDIR/tile.txt
echo    -5 15    15 60 hn >> $OUTDIR/tile.txt
echo    15 15    35 60 in >> $OUTDIR/tile.txt
echo    35 15    55 60 ln >> $OUTDIR/tile.txt
echo    55 15    75 60 mn >> $OUTDIR/tile.txt
echo    75 15    95 60 nn >> $OUTDIR/tile.txt
echo    95 15   115 60 on >> $OUTDIR/tile.txt
echo   115 15   135 60 pn >> $OUTDIR/tile.txt
echo   135 15   155 60 qn >> $OUTDIR/tile.txt
echo   155 15   175 60 rn >> $OUTDIR/tile.txt
echo   175 15   180 60 sn >> $OUTDIR/tile.txt

echo  -145 -56  -125 15 as >> $OUTDIR/tile.txt
echo  -125 -56  -105 15 bs >> $OUTDIR/tile.txt
echo  -105 -56   -85 15 cs >> $OUTDIR/tile.txt
echo   -85 -56   -65 15 ds >> $OUTDIR/tile.txt
echo   -65 -56   -45 15 es >> $OUTDIR/tile.txt
echo   -45 -56   -25 15 fs >> $OUTDIR/tile.txt
echo   -25 -56    -5 15 gs >> $OUTDIR/tile.txt
echo    -5 -56    15 15 hs >> $OUTDIR/tile.txt
echo    15 -56    35 15 is >> $OUTDIR/tile.txt
echo    35 -56    55 15 ls >> $OUTDIR/tile.txt
echo    55 -56    75 15 ms >> $OUTDIR/tile.txt
echo    75 -56    95 15 ns >> $OUTDIR/tile.txt
echo    95 -56   115 15 os >> $OUTDIR/tile.txt
echo   115 -56   135 15 ps >> $OUTDIR/tile.txt
echo   135 -56   155 15 qs >> $OUTDIR/tile.txt
echo   155 -56   175 15 rs >> $OUTDIR/tile.txt
echo   175 -56   180 15 ss >> $OUTDIR/tile.txt

cat $OUTDIR/tile.txt | head -1  | xargs -n 5  -P 8 bash -c $'

# projwin ulx uly lrx lry: 

for file in /gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/GRWL/GRWL_vector_to_rast/*.tif ; do 

filename=$(basename $file .tif )
gdal_translate --config GDAL_CACHEMAX  4000  -co COMPRESS=DEFLATE -co ZLEVEL=9  -eco  -projwin  $1 $4 $2 $3 $file $RAM/${filename}_$5.tif 
done 

#pkcomposite -co COMPRESS=DEFLATE -co ZLEVEL=9   -srcnodata -9999 -dstnodata -9999 -cr maxallbands  -i  $RAM/all_tif_$5.vrt -o $OUTDIR/GRWL/all_tif_$5.tif 
# pkfilter -nodata -9999 -co COMPRESS=DEFLATE -co ZLEVEL=9 -ot Int32 -of GTiff  -dx 30 -dy 30 -f mean  -d 30 -i $OUTDIR/GRWL/all_tif_$5.tif   -o $OUTDIR/GRWL/all_tif1km_$5.tif 

' _ 

exit 

gdalbuildvrt   -overwrite -srcnodata  -9999   -vrtnodata -9999   -te  $1 $2 $3 $4  $RAM/all_tif_$5.vrt   $INDIR/all_tif_sep.vrt 


gdalbuildvrt -overwrite  -srcnodata  -9999   -vrtnodata -9999   $RAM/all_tif.vrt       $OUTDIR/GRWL/all_tif1km_?.tif 
gdal_translate  -a_nodata -9999 -co COMPRESS=DEFLATE -co ZLEVEL=9  $RAM/all_tif.vrt  $OUTDIR/GRWL/grwl_mean.tif 

rm  $OUTDIR/tile.txt   $RAM/all_tif.vrt   $RAM/all_tif_?.vrt   





