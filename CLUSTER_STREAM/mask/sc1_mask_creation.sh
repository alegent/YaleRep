# bash /lustre/home/client/fas/sbsc/ga254/max_min_river/script/mask_creation.sh

#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=4:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /lustre/scratch/client/fas/sbsc/ga254/stdout 
#PBS -e /lustre/scratch/client/fas/sbsc/ga254/stderr

export INDIR=/lustre/scratch/client/fas/sbsc/sd566/global_wsheds/global_results_merged/filled_str_ord_maximum_max50x_lakes_manual_correction/
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/global_wsheds/tif_msk





for var1 in bioclim climate ; do 

export var1
for var2 in avg wavg ; do 
export var2 
	
ls   $INDIR/$var1/$var2/*.tif | xargs -n 1   -P 8  bash -c $' 

filename=$(basename  $1) 
pkgetmask -ot  Byte  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND   -min -10000 -max -9999  -data  0 -nodata 1 -i  $1  -o  $OUTDIR/${var1}_${var2}_${filename}_msk.tif  

' _ 
done 
done

for var1 in landuse ; do 
export var1
for var2 in avg  max  min  range  wavg  ; do 
export var2 
	
ls   $INDIR/$var1/$var2/*.tif | xargs -n 1   -P 8  bash -c $' 

filename=$(basename  $1) 
pkgetmask -ot  Byte  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND   -min 254 -max 255   -data  0 -nodata 1 -i  $1  -o  $OUTDIR/${var1}_${var2}_${filename}_msk.tif  

' _
done 
done

for var1 in soil  ; do 

export var1

for var2 in avg  max  min  range  wavg  ; do 

export var2 
	
ls   $INDIR/$var1/$var2/*.tif | xargs -n 1   -P 8  bash -c $' 

filename=$(basename  $1) 
pkgetmask -ot  Byte  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND   -min -10000 -max -9999  -data  0 -nodata 1 -i  $1  -o  $OUTDIR/${var1}_${var2}_${filename}_msk.tif  

' _

done 
done






ls   $INDIR/elevation/*.tif | xargs -n 1   -P 8  bash -c $' 

filename=$(basename  $1) 

pkgetmask -ot  Byte  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND   -min -10000 -max -9999  -data  0 -nodata 1 -i  $1  -o  $OUTDIR/elevation_${filename}_msk.tif  

' _


ls   $INDIR/slope/*.tif | xargs -n 1   -P 8  bash -c $' 

filename=$(basename  $1) 

pkgetmask -ot  Byte  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND   -min -10000 -max -9999  -data  0 -nodata 1 -i  $1  -o  $OUTDIR/slope_${filename}_msk.tif  

' _


ls   $INDIR/stream_topo/*.tif | xargs -n 1   -P 8  bash -c $' 

filename=$(basename  $1) 

pkgetmask -ot  Byte  -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND   -min -10000 -max -9999  -data  0 -nodata 1 -i  $1  -o  $OUTDIR/stream_topo__${filename}_msk.tif

' _  >  /lustre/home/client/fas/sbsc/ga254/max_min_river/stream_topo_nodata_count.txt 


exit 

# count pixel
ls   /lustre/scratch/client/fas/sbsc/ga254/dataproces/global_wsheds/tif_msk/*.tif | xargs -n 1 -P 4 bash -c $' echo $1 $(pkstat    -src_min -0   -src_max 1  -hist   -i $1  | awk \'{      printf("%i ",$2) } END  { printf("\\n")  }\'  )  ' _ >  $OUTDIR/nodata_data.txt

# troppo lento 
pkcomposite -ot Byte -co COMPRESS=DEFLATE -co ZLEVEL=9 -co INTERLEAVE=BAND -ot Byte   $(ls   /lustre/scratch/client/fas/sbsc/ga254/dataproces/global_wsheds/tif_msk/*.tif | xargs -n 1 echo -i)  -cr sum -o  /lustre/scratch/client/fas/sbsc/ga254/dataproces/global_wsheds/tif_msk/sum_tif.tif

exit 

