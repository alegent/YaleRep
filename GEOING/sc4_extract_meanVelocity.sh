# bash   /lustre/home/client/fas/sbsc/ga254/scripts/GEOING/sc4_extract_meanVelocity.sh
# qsub   /lustre/home/client/fas/sbsc/ga254/scripts/GEOING/sc4_extract_meanVelocity.sh 
# start branching
# modify file

#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=4:00:00
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

export DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING
export RAM=/dev/shm

ls /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/velocity_CRU/*.tif   /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/velocity_HadISST/*.tif   | xargs -n 1 -P 8 bash -c $'  

file=$1 
filename=$(basename $file .tif) 
dirname=$(dirname $file ) 

for PAR in mean median ; do 

rm -f $dirname/shp/${filename}_360x114global_$PAR.*

pkextract -polygon  -r $PAR   -f  "ESRI Shapefile" -srcnodata -9999    -s   /lustre/scratch/client/fas/sbsc/ga254/dataproces/SHAPE_NET/360x114global.shp  -i $file  -o ${dirname}/shp/${filename}_$PAR.shp
done 

' _ 


find /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEOING/velocity_models/*/*/*.tif   | xargs -n 1 -P 8 bash -c $'  

file=$1 
filename=$(basename $file .tif) 
dir1=$(basename $(dirname $file)  )
dir2=$( dirname $(dirname $file)  )

for PAR in mean median ; do 

rm -f ${dir2}_shp/$dir1/${filename}_$PAR.shp
pkextract -polygon  -r $PAR   -f  "ESRI Shapefile" -srcnodata -9999    -s   /lustre/scratch/client/fas/sbsc/ga254/dataproces/SHAPE_NET/360x114global.shp  -i $file  -o ${dir2}_shp/$dir1/${filename}_$PAR.shp
done 

' _ 

