# bash  /lustre/home/client/fas/sbsc/ga254/max_min_river/script/nodata_min_max.sh

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

echo $( basename $1 )   $(  gdalinfo  $1   | grep -e NoData | awk  \'{ gsub ("[=]", " " )  ; print  $3 }\' )  $(      gdalinfo -mm $1  | grep -e Computed | awk  \'{ gsub ("[=,]", " " )  ; print  $3 , $4  }\'    ) 

' _  >  /lustre/home/client/fas/sbsc/ga254/max_min_river/${var1}_${var2}_nodata_min_max.txt 

done 
done


for var1 in landuse ; do 

export var1

for var2 in avg  max  min  range  wavg  ; do 

export var2 
	
ls   $INDIR/$var1/$var2/*.tif | xargs -n 1   -P 8  bash -c $' 

echo $( basename $1 )   $(  gdalinfo  $1   | grep -e NoData | awk  \'{ gsub ("[=]", " " )  ; print  $3 }\' )  $(      gdalinfo -mm $1  | grep -e Computed | awk  \'{ gsub ("[=,]", " " )  ; print  $3 , $4  }\'    ) 

' _  >  /lustre/home/client/fas/sbsc/ga254/max_min_river/${var1}_${var2}_nodata_min_max.txt 

done 
done

ls   $INDIR/slope/*.tif | xargs -n 1   -P 8  bash -c $' 
echo $( basename $1 )   $(  gdalinfo  $1  | grep -e NoData | awk  \'{ gsub ("[=]", " " )  ; print  $3 }\' )  $(  gdalinfo -mm $1  | grep -e Computed | awk  \'{ gsub ("[=,]", " " )  ; print  $3 , $4  }\'    ) 
' _  >  /lustre/home/client/fas/sbsc/ga254/max_min_river/slope_nodata_min_max.txt 



ls   $INDIR/elevation/*.tif | xargs -n 1   -P 8  bash -c $' 

echo $( basename $1 )   $(  gdalinfo  $1   | grep -e NoData | awk  \'{ gsub ("[=]", " " )  ; print  $3 }\' )  $(      gdalinfo -mm $1  | grep -e Computed | awk  \'{ gsub ("[=,]", " " )  ; print  $3 , $4  }\'    ) 

' _  >  /lustre/home/client/fas/sbsc/ga254/max_min_river/elevation_nodata_min_max.txt 



ls   $INDIR/slope/*.tif | xargs -n 1   -P 8  bash -c $' 

echo $( basename $1 )   $(  gdalinfo  $1   | grep -e NoData | awk  \'{ gsub ("[=]", " " )  ; print  $3 }\' )  $(      gdalinfo -mm $1  | grep -e Computed | awk  \'{ gsub ("[=,]", " " )  ; print  $3 , $4  }\'    ) 

' _  >  /lustre/home/client/fas/sbsc/ga254/max_min_river/slope_nodata_min_max.txt 


ls   $INDIR/stream_topo/*.tif | xargs -n 1   -P 8  bash -c $' 

echo $( basename $1 )   $(  gdalinfo  $1   | grep -e NoData | awk  \'{ gsub ("[=]", " " )  ; print  $3 }\' )  $(      gdalinfo -mm $1  | grep -e Computed | awk  \'{ gsub ("[=,]", " " )  ; print  $3 , $4  }\'    ) 

' _  >  /lustre/home/client/fas/sbsc/ga254/max_min_river/stream_topo_nodata_min_max.txt 



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




