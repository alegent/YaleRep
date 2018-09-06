#!/bin/bash
#SBATCH -p scavenge
#SBATCH -n 1 -c 1  -N 1  
#SBATCH -t 2:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc01_rasterize_vector.sh.%A.%a.out
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc01_rasterize_vector.sh.%A.%a.err
#SBATCH --job-name=sc01_rasterize_vector.sh
#SBATCH --array=1-829

# sbatch /gpfs/home/fas/sbsc/ga254/scripts/GRWL/sc01_rasterize_vector.sh

# data from https://zenodo.org/record/1297434#.W4_713XBjNP

INDIR=/gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/GRWL/GRWL_vector_V01.01
OUTDIR=/gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/GRWL/GRWL_vector_to_rast

# file=/gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/MERIT/equi7/dem/EU/EU_048_000.tif

file=$(ls $INDIR/*.shp  | head -n $SLURM_ARRAY_TASK_ID | tail -1 )
filename=$(basename $file .shp )



gdal_rasterize -te $( getCornersOgr4Gwarp $file | awk '{ print int($1-1), int($2-1), int($3+1), int($4+1) }' ) -init -9999 -a_nodata -9999  -tr 0.00027777777777 0.00027777777777 -ot Int32 -a "width_m" -l $filename  $file  $OUTDIR/tmp_$filename.tif 
gdal_translate  -co COMPRESS=DEFLATE -co ZLEVEL=9  $OUTDIR/tmp_$filename.tif   $OUTDIR/$filename.tif 
rm -f $OUTDIR/tmp_$filename.tif 
