# variables derived from the dem following commands in http://www.gdal.org/gdaldem.html # gdaldem_slope 
# to check ls ?_?.tif  | xargs -n 1 -P 30 bash -c $' gdalinfo  -mm $1 |grep Max  | awk \'{ gsub("[=,]", " ") ;  print $3,$4  }\'  ' _ 
# find /mnt/data2/dem_variables/GMTED2010/{aspect,roughness,slope,tpi,tri}  -name *.tif | xargs -n 1 -P 10 rm ;

#   rm /scratch/fas/sbsc/ga254/stdout/*   /scratch/fas/sbsc/ga254/stderr/*

#  cd  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/md75_grd_tif
#  awk 'NR%4==1 {x="F"++i;}{ print >   "tiles4_list"x".txt" }'  tiles_list.txt  ; 
#  awk 'NR%8==1 {x="F"++i;}{ print >   "tiles8_list"x".txt" }'  tiles_list.txt  ; 
#  awk 'NR%16==1 {x="F"++i;}{ print >  "tiles16_list"x".txt" }'  tiles_list.txt  ; 

# cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles_list

# for km in 1 5 10 50 100 ; do qsub  -v km=$km   /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc5b_dem_variables_float_noMult_resKM.sh ; done

# bash  /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc5b_dem_variables_float_noMult_resKM.sh 5 

#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=24:00:00
#PBS -l nodes=1:ppn=8
#PBS -l mem=34
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr


INDIR_MI=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/mi75_grd_tif
INDIR_MD=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/md75_grd_tif
INDIR_MX=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/mx75_grd_tif
INDIR_MN=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/mn75_grd_tif

for var in mi md mx mn  ; do
rm -f  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/${var}75_grd_tif/${var}75_grd_tif.vrt
gdalbuildvrt -srcnodata -9999 -vrtnodata -9999 -te -180 -56  +180 +84  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/${var}75_grd_tif/${var}75_grd_tif.vrt  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/${var}75_grd_tif/?_?.tif  
done 

for var in sin cos Ew Nw ; do 
rm -f /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/aspect/tiles/${var}_md.vrt
gdalbuildvrt -srcnodata -9999 -vrtnodata -9999 -te -180 -56  +180 +84  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/aspect/tiles/${var}_md.vrt      /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/aspect/tiles/?_?_md_${var}.tif 
done 

for var in slope tri tpi vrm roughness aspect; do
rm -f  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/${var}/tiles/${var}_md.vrt 
gdalbuildvrt -srcnodata -9999 -vrtnodata -9999 -te -180 -56  +180 +84 /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/${var}/tiles/${var}_md.vrt      /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/${var}/tiles/?_?_md.tif 
done 

export INDIR_MI=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/mi75_grd_tif
export INDIR_MD=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/md75_grd_tif
export INDIR_MX=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/mx75_grd_tif
export INDIR_MN=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/mn75_grd_tif
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010

export RAM=/dev/shm
rm -rf /dev/shm/*
# km=$1

export res=$( expr $km \* 4)
export km=$km


# split the stak in 8 tiles Size is 172800 67200, so 43200 33600 

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
echo max of the max with file   $INDIR_MX/mx75_grd_tif_x${1}_y${2}.vrt 

gdal_translate  -of VRT  -srcwin  $xoff $yoff $xsize $ysize   $INDIR_MX/mx75_grd_tif.vrt  $INDIR_MX/mx75_grd_tif_x${1}_y${2}.vrt
pkfilter -of GTiff   -nodata -32768 -dx $res -dy $res   -f max -d $res -i $INDIR_MX/mx75_grd_tif_x${1}_y${2}.vrt  -o $OUTDIR/altitude/max_of_mx/tiles/x${1}_y${2}_km$km.tif  -co COMPRESS=LZW -co ZLEVEL=9 -ot Float32  

echo min of the min with file 

gdal_translate  -of VRT  -srcwin  $xoff $yoff $xsize $ysize   $INDIR_MI/mi75_grd_tif.vrt  $INDIR_MI/mi75_grd_tif_x${1}_y${2}.vrt
pkfilter -of GTiff   -nodata -32768 -dx $res -dy $res   -f min -d $res -i $INDIR_MI/mi75_grd_tif_x${1}_y${2}.vrt  -o $OUTDIR/altitude/min_of_mi/tiles/x${1}_y${2}_km$km.tif  -co COMPRESS=LZW -co ZLEVEL=9 -ot Float32  
 
echo mean of the mn with file  
gdal_translate  -of VRT  -srcwin  $xoff $yoff $xsize $ysize   $INDIR_MN/mn75_grd_tif.vrt  $INDIR_MN/mn75_grd_tif_x${1}_y${2}.vrt
pkfilter -of GTiff   -nodata -32768 -dx $res -dy $res   -f mean  -d $res -i $INDIR_MN/mn75_grd_tif_x${1}_y${2}.vrt  -o $OUTDIR/altitude/mean_of_mn/tiles/x${1}_y${2}_km$km.tif  -co COMPRESS=LZW -co ZLEVEL=9 -ot Float32  

echo median of the md with file  
gdal_translate  -of VRT  -srcwin  $xoff $yoff $xsize $ysize   $INDIR_MD/md75_grd_tif.vrt  $INDIR_MD/md75_grd_tif_x${1}_y${2}.vrt
pkfilter -of GTiff   -nodata -32768 -dx $res -dy $res   -f median  -d $res -i $INDIR_MD/md75_grd_tif_x${1}_y${2}.vrt  -o $OUTDIR/altitude/median_of_md/tiles/x${1}_y${2}_km$km.tif  -co COMPRESS=LZW -co ZLEVEL=9 -ot Float32  

echo stdev of mn with file 

pkfilter -of GTiff   -nodata -32768 -dx $res -dy $res   -f var  -d $res -i $INDIR_MN/mn75_grd_tif_x${1}_y${2}.vrt  -o $RAM/mn75_grd_tif_x${1}_y${2}_km$km.tif  -co COMPRESS=LZW -co ZLEVEL=9 -ot Float32  
gdal_calc.py   --NoDataValue=-9999 --co=COMPRESS=LZW  --co=ZLEVEL=9 -A  $RAM/mn75_grd_tif_x${1}_y${2}_km$km.tif   --calc="sqrt(A)" --type=Float32 --overwrite --outfile $OUTDIR/altitude/stdev_of_mn/tiles/x${1}_y${2}_km$km.tif
rm -f  $RAM/mn75_grd_tif_x${1}_y${2}_km$km.tif

echo stdev of md with file 

pkfilter -of GTiff   -nodata -32768 -dx $res -dy $res   -f var  -d $res -i $INDIR_MD/md75_grd_tif_x${1}_y${2}.vrt  -o $RAM/md75_grd_tif_x${1}_y${2}_km$km.tif  -co COMPRESS=LZW -co ZLEVEL=9 -ot Float32  
gdal_calc.py   --NoDataValue=-9999 --co=COMPRESS=LZW  --co=ZLEVEL=9 -A  $RAM/md75_grd_tif_x${1}_y${2}_km$km.tif   --calc="sqrt(A)" --type=Float32 --overwrite --outfile $OUTDIR/altitude/stdev_of_md/tiles/x${1}_y${2}_km$km.tif
rm -f  $RAM/md75_grd_tif_x${1}_y${2}_km$km.tif

INDIR=$INDIR_MD
mm=md

for TOPO in  slope tpi tri vrm roughness ; do 
    gdal_translate  -of VRT  -srcwin  $xoff $yoff $xsize $ysize   $OUTDIR/$TOPO/tiles/${TOPO}_${mm}.vrt   $OUTDIR/$TOPO/tiles/${TOPO}_${mm}_x${1}_y${2}.vrt

    for MAT in mean median min max ; do                                                                                                         
	echo  $TOPO  $MAT $res 
	pkfilter  -of GTiff   -nodata -9999 -dx $res -dy $res -f $MAT   -d $res -i $OUTDIR/$TOPO/tiles/${TOPO}_${mm}_x${1}_y${2}.vrt -o $OUTDIR/${TOPO}/$MAT/tiles/x${1}_y${2}_km$km.tif -co COMPRESS=LWZ -co ZLEVEL=9 -ot Float32
    done

    # stdev 
    pkfilter -nodata -9999  -co COMPRESS=LWZ -co ZLEVEL=9  -ot Float32   -dx $res -dy $res -f var -d $res -i $OUTDIR/stdev/tiles/${TOPO}_${mm}_x${1}_y${2}.vrt   -o $RAM/x${1}_y${2}_km$km.tif 
    gdal_calc.py  --NoDataValue=-9999   --co=COMPRESS=LWZ --co=ZLEVEL=9 -A   -o $RAM/x${1}_y${2}_km$km.tif   --calc="sqrt(A)" --type=Float32  --overwrite --outfile  $OUTDIR/${TOPO}/stdev/tiles/x${1}_y${2}_km$km.tif
    rm -f $RAM/x${1}_y${2}_km$km.tif 
done 

TOPO=aspect
for DER in sin cos Ew Nw ; do 

    gdal_translate  -of VRT  -srcwin  $xoff $yoff $xsize $ysize  $OUTDIR/$TOPO/tiles/${DER}_${mm}.vrt  $OUTDIR/$TOPO/tiles/${DER}_${mm}_x${1}_y${2}.vrt        
    for MAT in mean median min max ; do                                                                                                         
	echo  $TOPO  $MAT $res 
	pkfilter  -of GTiff     -nodata -9999 -dx $res -dy $res -f $MAT   -d $res -i  $OUTDIR/$TOPO/tiles/${DER}_${mm}_x${1}_y${2}.vrt   -o $OUTDIR/${TOPO}/$MAT/tiles/${DER}_x${1}_y${2}_km$km.tif -co COMPRESS=LWZ -co ZLEVEL=9 -ot Float32
    done

    # stdev 
    pkfilter  -of GTiff   -nodata -9999  -co COMPRESS=LWZ -co ZLEVEL=9  -ot Float32   -dx $res -dy $res -f var -d $res -i $OUTDIR/stdev/tiles/${TOPO}_${mm}_x${1}_y${2}.vrt   -o $RAM/${DER}_x${1}_y${2}_km$km.tif  
    gdal_calc.py  --NoDataValue=-9999   --co=COMPRESS=LWZ --co=ZLEVEL=9 -A   -o $RAM/${DER}_x${1}_y${2}_km$km.tif   --calc="sqrt(A)" --type=Float32  --overwrite --outfile  $OUTDIR/${TOPO}/stdev/tiles/${DER}_x${1}_y${2}_km$km.tif
    rm -f  $RAM/${DER}_x${1}_y${2}_km$km.tif  
done 

' _ 

rm -rf /dev/shm/*

exit 


