# calculate vrm  /home/fas/sbsc/ga254/scripts/SRTM/sc10_grass_vrm.sh 

# qsub /home/fas/sbsc/ga254/scripts/SRTM/sc10_grass_vrm.sh 


#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=6:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

export INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/altitude/tiles
export RAM=/dev/shm

export OUTGEO=/lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/vrm/tiles/


cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/SRTM/altitude/tiles/
source /lustre/home/client/fas/sbsc/ga254/scripts/general/create_location.sh  $OUTGEO  loc_tiles_96000_12000   $INDIR/tiles_96000_12000.tif


~/.grass7/addons/bin/r.vector.ruggedness.py  elevation=tiles_96000_12000 output=tiles_96000_12000_vrm 

r.out.gdal -c  createopt="COMPRESS=LZW,ZLEVEL=9" format=GTiff  type=Float32  input=tiles_96000_12000_vrm   output=$OUTGEO/tiles_96000_12000_vrm.tif 




