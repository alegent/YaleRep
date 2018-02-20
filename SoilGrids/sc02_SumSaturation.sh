#!/bin/bash
#SBATCH -p day
#SBATCH -n 1 -c 1 -N 1
#SBATCH -t 24:00:00
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc02_SumSaturation.sh.%J.out
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc02_SumSaturation.sh.%J.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email
#SBATCH --job-name=sc02_SumSaturation.sh


# sbatch /gpfs/home/fas/sbsc/ga254/scripts/SoilGrids/sc02_SumSaturation.sh

export DIR=/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/SoilGrids/AWC


# Upper Left  (-180.0000000,  84.0000000) (180d 0' 0.00"W, 84d 0' 0.00"N)
# Lower Left  (-180.0000000, -56.0000000) (180d 0' 0.00"W, 56d 0' 0.00"S)
# Upper Right ( 180.0000000,  84.0000000) (180d 0' 0.00"E, 84d 0' 0.00"N)
# Lower Right ( 180.0000000, -56.0000000) (180d 0' 0.00"E, 56d 0' 0.00"S)

#    xmin ymin xmax ymax 

echo -100 20  -90 30 a >  $DIR/tile.txt
echo  -90 10    0 84 b >> $DIR/tile.txt
echo    0 10   90 84 c >> $DIR/tile.txt
echo   90 10  180 84 d >> $DIR/tile.txt

echo -180 -56  -90 10 e >> $DIR/tile.txt
echo  -90 -56    0 10 f >> $DIR/tile.txt
echo    0 -56   90 10 g >> $DIR/tile.txt
echo   90 -56  180 10 h >> $DIR/tile.txt

# depth   0 5 15 30 60 100 200

head -1   $DIR/tile.txt | xargs -n 5  -P 1 bash -c $' 

for file in $DIR/*.tif ; do 
filename=$(basename $file .tif   )
gdalbuildvrt  -te $1 $2 $3 $4 -overwrite  $DIR/${filename}_$5.vrt $file
done 

gdal_calc.py -A $DIR/AWCtS_M_sl1_250m_$5.vrt   -B $DIR/AWCtS_M_sl2_250m_$5.vrt  -C $DIR/AWCtS_M_sl3_250m_$5.vrt   -D $DIR/AWCtS_M_sl4_250m_$5.vrt \
             -E $DIR/AWCtS_M_sl5_250m_$5.vrt   -F $DIR/AWCtS_M_sl6_250m_$5.vrt  -G $DIR/AWCtS_M_sl7_250m_$5.vrt --format=GTiff   --outfile=$DIR/../AWC_sum/AWCtS_M_slsum_250m_$5.tif \
             --co=COMPRESS=DEFLATE --co=ZLEVEL=9  --overwrite --NoDataValue=-1 --type=Float32   \
             --calc="( ((1/400) * ( (5      *  (A.astype(float) +   B.astype(float))) + \
                        (10     *  (B.astype(float) +   C.astype(float))) + \
                        (15     *  (C.astype(float) +   D.astype(float))) + \
                        (30     *  (D.astype(float) +   E.astype(float))) + \
                        (40     *  (E.astype(float) +   F.astype(float))) + \
                        (100    *  (F.astype(float) +   G.astype(float))) ))/ 200 * 0.5 )"
rm $DIR/AWCtS_M_sl*_250m_$5.vrt
' _ 

gdalbuildvrt  -overwrite    $DIR/../AWC_sum/AWCtS_M_slsum_250m.vrt   $DIR/../AWC_sum/AWCtS_M_slsum_250m_*.tif 


