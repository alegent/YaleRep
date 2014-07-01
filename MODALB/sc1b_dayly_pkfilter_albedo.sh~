# calculate the albdedo days based on pkfilter 


# for tile in $(  awk '{  if (NR>1 ) print $1 }'  /lustre0/scratch/ga254/dem_bj/MODALB/geo_file/tile_lat_long_10d.txt   ) ; do qsub -v tile=$tile /lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/MODALB/sc1b_dayly_pkfilter_albedo.sh   ; sleep 2000   ; done

#PBS -S /bin/bash 
#PBS -q fas_normal            
#PBS -l mem=1gb
#PBS -l walltime=1:00:00   
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /lustre0/scratch/ga254/stdout 



export  tile=$1
# export tile=$tile 

export INDIR=/lustre0/scratch/ga254/dem_bj/MODALB/0.3_5.0.um.00-04.WS.c004.v2.0
export DIRTILE=/lustre0/scratch/ga254/dem_bj/MODALB/0.3_5.0.um.00-04.WS.c004.v2.0_tiles 

export DIRTILE_MERGE=/lustre0/scratch/ga254/dem_bj/MODALB/0.3_5.0.um.00-04.WS.c004.v2.0_tiles_merge
export DIRPK_MERGE=/lustre0/scratch/ga254/dem_bj/MODALB/0.3_5.0.um.00-04.WS.c004.v2.0_day_merge_estimation_pkfilter
export DIRPK_TILE=/lustre0/scratch/ga254/dem_bj/MODALB/0.3_5.0.um.00-04.WS.c004.v2.0_day_tiles_estimation_pkfilter
export DIRPK=/lustre0/scratch/ga254/dem_bj/MODALB/0.3_5.0.um.00-04.WS.c004.v2.0_day_estimation_pkfilter



# ls $INDIR/*.tif | xargs -n 1 -P 8 bash -c   $'  

# file=$1
# filename=$(basename $file .tif)

# ulx=$( awk -v tile=$tile \'{ if($1==tile) print $4   }\'  /lustre0/scratch/ga254/dem_bj/MODALB/geo_file/tile_lat_long_10d.txt) 
# uly=$( awk -v tile=$tile \'{ if($1==tile) print $5   }\'  /lustre0/scratch/ga254/dem_bj/MODALB/geo_file/tile_lat_long_10d.txt) 
# lrx=$( awk -v tile=$tile \'{ if($1==tile) print $6   }\'  /lustre0/scratch/ga254/dem_bj/MODALB/geo_file/tile_lat_long_10d.txt)  
# lry=$( awk -v tile=$tile \'{ if($1==tile) print $7   }\'  /lustre0/scratch/ga254/dem_bj/MODALB/geo_file/tile_lat_long_10d.txt)


# gdal_translate  -projwin  $ulx $uly $lrx $lry   -co COMPRESS=LZW -co ZLEVEL=9  $file     $DIRTILE/${filename}_${tile}.tif 

# ' _  

# gdalbuildvrt  -separate -resolution user    -tr  0.002083333333333 0.002083333333333  -overwrite      $DIRTILE_MERGE/${tile}.vrt    $DIRTILE/*_${tile}.tif 
# gdal_translate    -co COMPRESS=LZW -co ZLEVEL=9   $DIRTILE_MERGE/${tile}.vrt    $DIRTILE_MERGE/${tile}.tif

rm -f $DIRPK_MERGE/${tile}.tif 
 pkfilter $(for ((M=1;M<24;++M));do  echo " -win $(($M*16-15)) " ; done  ; echo "-win 366" ;   for ((M=1;M<=365;++M));do  echo " -wout $M -fwhm 1" ; done  )   -i  $DIRTILE_MERGE/${tile}.tif   -o  $DIRPK_MERGE/${tile}.tif   -interp cspline


exit 



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
