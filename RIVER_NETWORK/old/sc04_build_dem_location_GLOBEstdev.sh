#!/bin/bash
#SBATCH -p week
#SBATCH -n 1 -c 1 -N 1  
#SBATCH -t 168:00:00
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc04_build_dem_location_GLOBEstdev.sh.%J.out
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc04_build_dem_location_GLOBEstdev.sh.%J.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email

# sacct -j 623622   --format=jobid,MaxVMSize,start,end,CPUTImeRaw,NodeList,ReqCPUS,ReqMem,Elapsed,Timelimit 
# sstat  -j   $SLURM_JOB_ID.batch   --format=JobID,MaxVMSize 

# for RADIUS in 31 61 71 81 91 101 111 121 131 141 151   ; do sleep 60 ;   sbatch  --export=RADIUS=$RADIUS -J sc04_build_dem_location_GLOBEstdev.sh_$RADIUS.sh  /gpfs/home/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc04_build_dem_location_GLOBEstdev.sh  ; done 
# for RADIUS in 161 171 ; do sleep 60 ;   sbatch  --export=RADIUS=$RADIUS -J sc04_build_dem_location_GLOBEstdev.sh_$RADIUS.sh  /gpfs/home/fas/sbsc/ga254/scripts/RIVER_NETWORK/sc04_build_dem_location_GLOBEstdev.sh  ; done 

cd /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/grassdb 
export DIR=/gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK

rm -f   /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/grassdb/loc_river_fill_GLOBE/PERMANENT/.gislock
source  /gpfs/home/fas/sbsc/ga254/scripts/general/enter_grass7.0.2.sh   /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/grassdb/loc_river_fill_GLOBE/PERMANENT 
rm -f   /gpfs/scratch60/fas/sbsc/ga254/grace0/dataproces/RIVER_NETWORK/grassdb/loc_river_fill_GLOBE/PERMANENT/.gislock

# # compute standard deviation 

# r.mask -r  --quiet
# g.region raster=UNIT3753,UNIT4000
# r.patch  output=UNIT3753_4000  input=UNIT3753,UNIT4000   --o
# g.region raster=UNIT3753_4000
# r.mask  raster=UNIT3753_4000 --o # inserito a mano per tutte le computazioni 

echo standard deviation world 

r.neighbors -c   input=be75_grd_LandEnlarge_GLOBE    output=be75_grd_LandEnlarge_std${RADIUS}_GLOBE  method=stddev  size=${RADIUS} --overwrite

sstat  -j   $SLURM_JOB_ID.batch   --format=JobID,MaxVMSize 

