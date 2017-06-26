# qsub   /lustre/home/client/fas/sbsc/ga254/scripts/HOTSPOT/sc10_predict_extract.sh

#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=4:00:00 
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

rm -f /lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT/Predicts/360x114global_*.*
for PAR in mean median ; do 
pkextract -polygon -r $PAR  -f  "ESRI Shapefile" -srcnodata -9999  -s   /lustre/scratch/client/fas/sbsc/ga254/dataproces/SHAPE_NET/360x114global.shp  -i /lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT/Predicts/lbii.tif -o /lustre/scratch/client/fas/sbsc/ga254/dataproces/HOTSPOT/Predicts/360x114global_$PAR.shp 

done 
