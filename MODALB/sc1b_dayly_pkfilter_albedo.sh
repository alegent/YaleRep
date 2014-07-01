# calculate the albdedo days based on pkfilter 


# for tile in $( awk '{ if (NR>1 ) print $1 }'  /lustre0/scratch/ga254/dem_bj/MODALB/geo_file/tile_lat_long_10d.txt   ) ; do qsub -v tile=$tile   /lustre/home/client/fas/sbsc/ga254/scripts/MODALB/sc1b_dayly_pkfilter_albedo.sh   ; sleep 2000   ; done
# bash    /lustre/home/client/fas/sbsc/ga254/scripts/MODALB/sc1b_dayly_pkfilter_albedo.sh     h18v05 

# qsub -v tile=h18v05  /lustre/home/client/fas/sbsc/ga254/scripts/MODALB/sc1b_dayly_pkfilter_albedo.sh 

#PBS -S /bin/bash 
#PBS -q fas_normal            
#PBS -l walltime=1:00:00:00   
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout 
#PBS -e /scratch/fas/sbsc/ga254/stderr  

# export tile=$1
# export tile=h18v05

export INDIR=/scratch/fas/sbsc/ga254/dataproces/MODALB/0.3_5.0.um.00-04.WS.c004.v2.0
export DIRTILE=/scratch/fas/sbsc/ga254/dataproces/MODALB/0.3_5.0.um.00-04.WS.c004.v2.0_tiles 
export DIRTILE_MERGE=/scratch/fas/sbsc/ga254/dataproces/MODALB/0.3_5.0.um.00-04.WS.c004.v2.0_tiles_merge
export DIRPK_MERGE=/scratch/fas/sbsc/ga254/dataproces/MODALB/0.3_5.0.um.00-04.WS.c004.v2.0_day_merge_estimation_pkfilter
export DIRPK_TILE=/scratch/fas/sbsc/ga254/dataproces/MODALB/0.3_5.0.um.00-04.WS.c004.v2.0_day_tiles_estimation_pkfilter
export DIRPK=/scratch/fas/sbsc/ga254/dataproces/MODALB/0.3_5.0.um.00-04.WS.c004.v2.0_day_estimation_pkfilter

ls $INDIR/*.tif | xargs -n 1 -P 4 bash -c   $'  

file=$1
filename=$(basename $file .tif)

ulx=$( awk -v tile=$tile \'{ if($1==tile) print $4   }\'  /scratch/fas/sbsc/ga254/dataproces/MODALB/geo_file/tile_lat_long_10d.txt) 
uly=$( awk -v tile=$tile \'{ if($1==tile) print $5   }\'  /scratch/fas/sbsc/ga254/dataproces/MODALB/geo_file/tile_lat_long_10d.txt) 
lrx=$( awk -v tile=$tile \'{ if($1==tile) print $6   }\'  /scratch/fas/sbsc/ga254/dataproces/MODALB/geo_file/tile_lat_long_10d.txt)  
lry=$( awk -v tile=$tile \'{ if($1==tile) print $7   }\'  /scratch/fas/sbsc/ga254/dataproces/MODALB/geo_file/tile_lat_long_10d.txt)

gdal_translate  -projwin  $ulx $uly $lrx $lry   -co COMPRESS=LZW -co ZLEVEL=9  $file     $DIRTILE/${filename}_${tile}.tif 

' _  


# replicate of 3 times + last one 

echo create the merge tile   $DIRTILE_MERGE/${tile}.tif

rm -f  $DIRTILE_MERGE/${tile}.vrt
gdalbuildvrt  -separate -resolution user    -tr  0.002083333333333 0.002083333333333  -overwrite  $DIRTILE_MERGE/${tile}.vrt $DIRTILE/AlbMap.WS.c004.v2.0.00-04.???.0.3_5.0_${tile}.tif $DIRTILE/AlbMap.WS.c004.v2.0.00-04.???.0.3_5.0_${tile}.tif $DIRTILE/AlbMap.WS.c004.v2.0.00-04.???.0.3_5.0_${tile}.tif  $DIRTILE/AlbMap.WS.c004.v2.0.00-04.001.0.3_5.0_${tile}.tif

gdal_translate    -co COMPRESS=LZW -co ZLEVEL=9   $DIRTILE_MERGE/${tile}.vrt    $DIRTILE_MERGE/${tile}.tif

#  the  for ((M=366;M<=730;++M)) is usefull to keep the prediction only in the central part of the dataset. Means 1 year. 

echo start the interpolation for file    $DIRPK_MERGE/${tile}.tif

BW=40 

rm -f  $DIRPK_MERGE/${tile}.tif

pkfilter     -ot Float32 -co BIGTIFF=YES -co COMPRESS=LZW -co ZLEVEL=9  $( for s in 1 2 3 ; do  for ((M=1;M<24;++M)); do  echo " -win $((($M*16-15) + 365 * ( $s -1 )  )) " ; done ; done ; echo -win 1095  ;  for ((M=366;M<=730;++M)); do  echo " -wout $M -fwhm $BW" ; done)   -i  $DIRTILE_MERGE/${tile}.tif    -o  $DIRPK_MERGE/${tile}.tif   -interp cspline_periodic 

checkjob -v $PBS_JOBID

exit 






gdal_translate   -co COMPRESS=LZW -co ZLEVEL=9     -projwin   $(getCorners4Gtranslate  h18v05_small.tif)  h18v05.tif h18v05_small2.tif 







rm -f $DIRPK_MERGE/${tile}.tif 
pkfilter -co BIGTIFF=YES   -co COMPRESS=LZW -co ZLEVEL=9  $(for ((M=1;M<24;++M));do  echo " -win $(($M*16-15)) " ; done  ; echo "-win 366" ;   for ((M=1;M<=365;++M));do  echo " -wout $M -fwhm 1" ; done  )   -i  $DIRTILE_MERGE/${tile}.tif   -o  $DIRPK_MERGE/${tile}.tif   -interp cspline_periodic 

pkfilter -co BIGTIFF=YES   -co COMPRESS=LZW -co ZLEVEL=9    $(echo "-win -28 -win -12" ;  for ((M=1;M<24;++M));do  echo " -win $(($M*16-15)) " ; done  ; echo "-win 366 -win 382 -win 398 " ;   for ((M=-28;M<=398;++M));do  echo " -wout $M -fwhm 1" ; done  )   -i  $DIRTILE_MERGE/${tile}.tif   -o  $DIRPK_MERGE/${tile}.tif   -interp cspline_periodic 

exit 


# here in plotting procedure 


# gdal_translate   -co COMPRESS=LZW -co ZLEVEL=9     -projwin   $(getCorners4Gtranslate  h18v05_small.tif)  h18v05.tif h18v05_small2.tif

tile=h18v05

for BW in 40 ; do 

pkfilter -ot Float32 -co BIGTIFF=YES   -co COMPRESS=LZW -co ZLEVEL=9  $( for s in 1 2 3 ; do  for ((M=1;M<24;++M)); do  echo " -win $((($M*16-15) + 365 * ( $s -1 )  )) " ; done ; done ; echo -win 1095  ;  for ((M=366;M<=730;++M)); do  echo " -wout $M -fwhm $BW" ; done  )    -i  $DIRTILE_MERGE/h18v05_small2.tif    -o  $DIRPK_MERGE/${tile}.tif   -interp cspline_periodic 

for pix in 2 5 8 ; do 


gdallocationinfo  -valonly   $DIRPK_MERGE/${tile}.tif  $pix $pix    > test_365_BW${BW}p$pix.txt  
gdallocationinfo  -valonly   $DIRTILE_MERGE/h18v05_small2.tif $pix $pix  > test_24_BW${BW}p$pix.txt 

echo "
1
17
33
49
65
81
97
113
129
145
161
177
193
209
225
241
257
273
289
305
321
337
353
"  >  day_24.txt 

# for s in 1 2 3 ; do  for ((M=1;M<24;++M)); do  echo " $((($M*16-15) + 365 * ( $s -1 )  )) " ; done ; done > day_24.txt 
# echo  1095 >> day_24.txt 

paste -d " "    day_24.txt   test_24_BW${BW}p$pix.txt    > aod_24_BW${BW}p${pix}.txt
paste -d " "  <(seq 366 730)  test_365_BW${BW}p$pix.txt    > aod_365_BW${BW}p$pix.txt  

rm  test_365_BW${BW}p$pix.txt   test_24_BW${BW}p$pix.txt   day_24.txt 
done 
done 



head aod_365_BW40p8.txt  ; tail  aod_365_BW40p8.txt 












HOUSING10 -e POP10 -e Area -e  HunitDens -e PopDens | awk '{  if  ($1=="HunitDens") { printf( "%s\n", $4)}  else {  printf("%s ", $4) } }'  | awk '{if ( $4!="(null)" )  print}' >> $INDIR/$filename.txt 

ogrinfo -al  -geom=NO  Emberiza_affinis.shp  | grep -e OccCode -e  