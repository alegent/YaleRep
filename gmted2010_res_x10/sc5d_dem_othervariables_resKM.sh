# variables derived from the dem following commands in http://www.gdal.org/gdaldem.html # gdaldem_slope 
# to check ls *.tif  | xargs -n 1 -P 30 bash -c $' gdalinfo  -mm $1 |grep Max  | awk \'{ gsub("[=,]", " ") ;  print $3,$4  }\'  ' _ 

# run after
# /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc5b_dem_variables_float_noMult_resKM.sh 

#  for km in 1 5 10 50 100 ; do qsub  -v km=$km  /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc5d_dem_othervariables_resKM.sh ; done 
# bash  /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc5d_dem_othervariables_resKM.sh  10 
# rm    /lustre0/scratch/ga254/stderr/*  ; rm    /lustre0/scratch/ga254/stdout/*


# take the greenland value from /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/altitude/stdev_of_mn/altitude_stdev_of_mn_km1.tif  and use in the tiles/sd75_grd_tif/ 

# export IN=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010
# export SHP=$IN/tiles/shp
# export RAM=/dev/shm

# mkdir /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/sd75_grd_tif/greenland
# gdal_translate -a_nodata -1 -co COMPRESS=LZW  -co ZLEVEL=9   -projwin $(~/bin/getCorners4Gtranslate $SHP/green_land7.5arc-sec_msk.tif) $IN/altitude/stdev_of_mn/altitude_stdev_of_mn_km1.tif  $IN/tiles/sd75_grd_tif/greenland/sd30_grd_greenland.tif

# gdalwarp -r cubicspline -co COMPRESS=LZW  -co ZLEVEL=9   -tr 0.002083333333333 0.002083333333333  $IN/tiles/sd75_grd_tif/greenland/sd30_grd_greenland.tif $IN/tiles/sd75_grd_tif/greenland/sd75_grd_greenland.tif 

# pksetmask -co COMPRESS=LZW -co ZLEVEL=9 -i $IN/tiles/sd75_grd_tif/greenland/sd75_grd_greenland.tif -m $SHP/green_land7.5arc-sec_msk.tif -msknodata 0 -nodata 0 -o $IN/tiles/sd75_grd_tif/greenland/sd75_grd_greenland_msk.tif

# echo 2_0.tif 3_0.tif 4_0.tif | xargs -n 1 -P 3 bash -c $' 
# file=$1
# filename=$(basename $file .tif )
# geo_string=$(getCorners4Gtranslate  $file  )

# ulx=$( echo $geo_string | awk \'{  print $1 }\' ) ; uly=$( echo $geo_string | awk \'{  print $2 }\' ) 
# lrx=$( echo $geo_string | awk \'{  print $3 }\' ) ; lry=$( echo $geo_string | awk \'{  print $4 }\' ) 
 
# pkcomposite -ot Int16  -ulx $ulx -uly $uly -lrx $lrx -lry $lry -co COMPRESS=LZW -co ZLEVEL=9 -srcnodata 0 -dstnodata 0 -cr overwrite -i $IN/tiles/sd75_grd_tif/$file -i $IN/tiles/sd75_grd_tif/greenland/sd75_grd_greenland_msk.tif -o  $RAM/${filename}_greenland_inst.tif

# pkreclass -of GTiff -ot Int16 -c -32768 -r 0 -co COMPRESS=LZW -co ZLEVEL=9 -i $RAM/${filename}_greenland_inst.tif -o  $IN/tiles/sd75_grd_tif/greenland/${filename}_greenland_inst.tif
# rm -f  $RAM/${filename}_greenland_inst.tif
# ' _ 


#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=8:00:00 
#PBS -l mem=34gb
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr


export INDIR_SD=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/sd75_grd_tif
export OUTDIR_SD=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/altitude/stdev_pulled/tiles
export OUTDIR_DER=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/derived_var
export TMP=/tmp
export RAM=/dev/shm

rm -f $RAM/*

# km=$1

export res=$( expr $km \* 4)
export km=$km
export P=$( expr $res \* $res)  # dividend for the pulled SD
export p=$( expr $P - 1 )       # dividend for the pulled SD 

# pulled standard deviation see 
# http://en.wikipedia.org/wiki/Pooled_variance 
# C = 15 * sd^2                  =  D=sd^2
# =SQRT(SUM(C1:C16)/(15*16))    =  SQRT(SUM(D1:D16)/16)


echo 0         0  43200 33600   > $RAM/tiles_xoff_yoff.txt
echo 43200     0  43200 33600  >> $RAM/tiles_xoff_yoff.txt
echo 86400     0  43200 33600  >> $RAM/tiles_xoff_yoff.txt
echo 129600    0  43200 33600  >> $RAM/tiles_xoff_yoff.txt
echo 0      33600 43200 33600  >> $RAM/tiles_xoff_yoff.txt
echo 43200  33600 43200 33600  >> $RAM/tiles_xoff_yoff.txt
echo 86400  33600 43200 33600  >> $RAM/tiles_xoff_yoff.txt
echo 129600 33600 43200 33600  >> $RAM/tiles_xoff_yoff.txt

cat $RAM/tiles_xoff_yoff.txt | xargs -n 4 -P 8 bash -c $' 

xoff=$1
yoff=$2
xsize=$3
ysize=$4

# 30 min for this 
# echo max of the max with file   $INDIR_MX/mx75_grd_tif_x${1}_y${2}.vrt 

gdal_translate  -of VRT  -srcwin  $xoff $yoff $xsize $ysize   $INDIR_SD/sd75_grd_tif.vrt  $INDIR_SD/sd75_grd_tif_x${1}_y${2}.vrt

oft-calc   -ot Float64  $INDIR_SD/sd75_grd_tif_x${1}_y${2}.vrt   $OUTDIR_SD/x${1}_y${2}_km$km.tif  <<EOF
1
#1 #1 *
EOF

pkfilter  -co COMPRESS=LZW   -dx $res -dy $res   -f sum  -d $res -i   $OUTDIR_SD/x${1}_y${2}_km$km.tif  -o  $RAM/x${1}_y${2}_km${km}_sum.tif

rm -f   $OUTDIR_SD/x${1}_y${2}_km$km.tif 

oft-calc -ot Float32   $RAM/x${1}_y${2}_km${km}_sum.tif  $OUTDIR_SD/x${1}_y${2}_p${P}sd_km${km}.tif  <<EOF
1
#1 $P / 0.5 ^
EOF

oft-calc -ot Float32  $RAM/x${1}_y${2}_km${km}_sum.tif   $OUTDIR_SD/x${1}_y${2}_p${p}sd_km${km}.tif   <<EOF
1
#1 $p / 0.5 ^
EOF

rm -f  $RAM/x${1}_y${2}_km${km}_sum.tif


# sd of the sd 

pkfilter -of  GTiff   -ot Float32   -co COMPRESS=LZW    -dx $res -dy $res  -f stdev  -d $res  -i   $INDIR_SD/sd75_grd_tif_x${1}_y${2}.vrt  -o   $OUTDIR_SD/x${1}_y${2}_sd_km${km}.tif

'  _ 

rm -f $RAM/*
# segue  /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc6b_dem_variables_merge_by_vrt_translate_resKM.sh 