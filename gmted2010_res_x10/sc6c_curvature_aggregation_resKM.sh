# variables derived from the dem following commands in http://www.gdal.org/gdaldem.html # gdaldem_slope 
# to check ls ?_?.tif  | xargs -n 1 -P 30 bash -c $' gdalinfo  -mm $1 |grep Max  | awk \'{ gsub("[=,]", " ") ;  print $3,$4  }\'  ' _ 
# find /mnt/data2/dem_variables/GMTED2010/{aspect,roughness,slope,tpi,tri}  -name *.tif | xargs -n 1 -P 10 rm ;

#   rm /scratch/fas/sbsc/ga254/stdout/*   /scratch/fas/sbsc/ga254/stderr/*

#  cd  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles/md75_grd_tif
#  awk 'NR%4==1 {x="F"++i;}{ print >   "tiles4_list"x".txt" }'  tiles_list.txt  ; 
#  awk 'NR%8==1 {x="F"++i;}{ print >   "tiles8_list"x".txt" }'  tiles_list.txt  ; 
#  awk 'NR%16==1 {x="F"++i;}{ print >  "tiles16_list"x".txt" }'  tiles_list.txt  ; 

# cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/tiles_list

# for km in 1 5 10 50 100 ;  do for DIR in  dx dxx dy dyy pcurv tcurv  ;  do qsub  -v km=$km,DIR=$DIR   /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc6c_curvature_aggregation_resKM.sh ; done ; done 

# bash /home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc6c_curvature_aggregation_resKM.sh  10 dx

#PBS -S /bin/bash 
#PBS -q fas_long
#PBS -l walltime=8:00:00
#PBS -l nodes=1:ppn=8
#PBS -l mem=34gb
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

# km=$1
# DIR=$2

export INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geomorphon/tiles/$DIR

export RAM=/dev/shm
rm -rf  /dev/shm/* 

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


echo max of the max with file   $INDIR_MX/mx75_grd_tif_x${1}_y${2}.vrt 

gdal_translate  -of VRT  -srcwin  $xoff $yoff $xsize $ysize   $INDIR/md75_grd_tif0.tif  $RAM/x${1}_y${2}.vrt


for MAT in mean median min max ; do                                                                                                         
echo  $MAT $res 
pkfilter -co COMPRESS=LZW -co ZLEVEL=9 -ot Float32   -of GTiff   -nodata -9999 -dx $res -dy $res -f $MAT   -d $res -i  $RAM/x${1}_y${2}.vrt    -o  $INDIR/$MAT/tiles/x${1}_y${2}_km$km.tif 
done

# stdev 
pkfilter -of GTiff  -nodata -9999  -co COMPRESS=LZW -co ZLEVEL=9  -ot Float32   -dx $res -dy $res -f var -d $res -i  $RAM/x${1}_y${2}.vrt   -o  $RAM/x${1}_y${2}_km$km.tif  
gdal_calc.py --NoDataValue=-9999 --co=COMPRESS=LZW --co=ZLEVEL=9 -A  $RAM/x${1}_y${2}_km$km.tif     --calc="sqrt(A)" --type=Float32  --overwrite --outfile  $INDIR/stdev/tiles/x${1}_y${2}_km$km.tif  
rm -f $RAM/x${1}_y${2}_km$km.tif   $RAM/x${1}_y${2}.vrt

' _ 

