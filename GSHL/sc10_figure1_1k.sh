#!/bin/bash
#SBATCH -p scavenge
#SBATCH -J sc10_figure1_1k.sh
#SBATCH -n 1 -c 1 -N 1  
#SBATCH -t 24:00:00
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc10_figure1_1k.sh.%J.out
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc10_figure1_1k.sh.%J.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email

# sbatch   /gpfs/home/fas/sbsc/ga254/scripts/GSHL/sc10_figure1_1k.sh

module load Apps/R/3.0.3
module load Rpkgs/RASTER/2.5.2
module load Rpkgs/RGDAL/0.9-3


R --vanilla --no-readline   -q  <<'EOF' 

library( raster , lib.loc="/gpfs/apps/hpc/Rpkgs/RASTER/2.5.2/3.0/")

# library(rasterVis)
# library( rgdal , lib.loc="/gpfs/apps/hpc/Rpkgs/RGDAL/0.9-3/3.0")
# library( sp )
# require(raster)
# ibrary( rgdal , lib.loc="/gpfs/apps/hpc/Rpkgs/RGDAL/0.9-3/")
# equire(rasterVis)

bin = raster("/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/GSHL/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin_ct.tif") 



EOF
