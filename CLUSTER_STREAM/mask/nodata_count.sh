# bash /lustre/home/client/fas/sbsc/ga254/max_min_river/script/nodata_count.sh

#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=4:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /lustre/scratch/client/fas/sbsc/ga254/stdout 
#PBS -e /lustre/scratch/client/fas/sbsc/ga254/stderr



export INDIR=/lustre/scratch/client/fas/sbsc/sd566/global_wsheds/global_results_merged/filled_str_ord_maximum_max50x_lakes_manual_correction/

for var1 in bioclim climate ; do 

export var1

for var2 in avg wavg ; do 

export var2 
	
ls   $INDIR/$var1/$var2/*.tif | xargs -n 1   -P 8  bash -c $' 

filename=$(basename  $1) 

echo $filename $(pkstat -hist   -src_min -10000  -src_max -9999  -i  $1   | grep -v " 0")

' _   >  /lustre/home/client/fas/sbsc/ga254/max_min_river/${var1}_${var2}_nodata_count.txt 

done 
done

for var1 in landuse ; do 

export var1

for var2 in avg  max  min  range  wavg  ; do 

export var2 
	
ls   $INDIR/$var1/$var2/*.tif | xargs -n 1   -P 8  bash -c $' 

filename=$(basename  $1) 

echo $filename $(pkstat -hist   -src_min 254  -src_max 255  -i  $1   | grep -v " 0")

' _  >  /lustre/home/client/fas/sbsc/ga254/max_min_river/${var1}_${var2}_nodata_count.txt 

done 
done

ls   $INDIR/elevation/*.tif | xargs -n 1   -P 8  bash -c $' 

filename=$(basename  $1) 

echo $filename $(pkstat -hist   -src_min -10000  -src_max -9999  -i  $1   | grep -v " 0")

' _  >  /lustre/home/client/fas/sbsc/ga254/max_min_river/elevation_nodata_count.txt 



ls   $INDIR/slope/*.tif | xargs -n 1   -P 8  bash -c $' 

filename=$(basename  $1) 

echo $filename $(pkstat -hist   -src_min -10000  -src_max -9999  -i  $1   | grep -v " 0")

' _  >  /lustre/home/client/fas/sbsc/ga254/max_min_river/slope_nodata_count.txt 


ls   $INDIR/stream_topo/*.tif | xargs -n 1   -P 8  bash -c $' 

filename=$(basename  $1) 

echo $filename $(pkstat -hist   -src_min -10000  -src_max -9999  -i  $1   | grep -v " 0")

' _  >  /lustre/home/client/fas/sbsc/ga254/max_min_river/stream_topo_nodata_count.txt 



exit 









bioclim/avg
bioclim/wavg

climate/avg
climate/wavg

landuse/avg
landuse/max
landuse/min
landuse/range
landuse/wavg

soil/avg
soil/max
soil/min
soil/range
soil/wavg

elevation

slope

stream_topo





soil/soil_raw_names/


# max=$(grep $filename  /lustre/home/client/fas/sbsc/ga254/max_min_river/${var1}_${var2}_nodata_min_max.txt  | awk \'{ print int ($4)  }\' )
# min=$(grep $filename  /lustre/home/client/fas/sbsc/ga254/max_min_river/${var1}_${var2}_nodata_min_max.txt  | awk \'{ print $4 - 1 }\' )

# echo min  $min  max  $max 



