#!/bin/bash
#SBATCH -p day
#SBATCH -n 1 -c 1 -N 1
#SBATCH -t 24:00:00
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/no2_global_calc.sh.%J.out 
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/no2_global_calc.sh.%J.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email
#SBATCH --job-name=no2_global_calc.sh

# sbatch /gpfs/home/fas/sbsc/ga254/scripts/GRDC/no2_global_calc.sh

find  /tmp/     -user $USER   2>/dev/null  | xargs -n 1 -P 1 rm -ifr  
find  /dev/shm  -user $USER   2>/dev/null  | xargs -n 1 -P 1 rm -ifr  

cd  /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/GRDC 

# remove some negative value in the runoff  mm/yr over a 30-minute (0.5 degree) pixel.  
pksetmask -of GTiff  -ot Float32 -co COMPRESS=DEFLATE -co ZLEVEL=9 \
-m runoff/cmp_ro.grd  -msknodata -9999  -p '='  -nodata -9999 \
-m runoff/cmp_ro.grd  -msknodata 0  -p '<'  -nodata 0  -i runoff/cmp_ro.grd   -o /dev/shm/cmp_ro.tif 

# /0.50deg-Area_prj6842.tif   km2 in 1/2 degree 
gdalbuildvrt -te $(getCorners4Gwarp   runoff/cmp_ro.grd )  -allow_projection_difference  -overwrite  -separate  /dev/shm/Overall_TN.vrt  /dev/shm/cmp_ro.tif  /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/GEO_AREA/area_tif/0.50deg-Area_prj6842.tif  

# get mm per km2  dm=mm/100  dm=km*10000  ... 10000/100 = 100 
oft-calc -ot Float32  /dev/shm/Overall_TN.vrt  /dev/shm/cmp_ro_km2.tif  <<EOF
1
#1 #2 * 100 * 
EOF
# output liter 

# impose sea mask -9999
pksetmask -ot Float32 -co COMPRESS=DEFLATE -co ZLEVEL=9 -m  /dev/shm/cmp_ro.tif  -msknodata -9999   -p '='  -nodata -9999 -i  /dev/shm/cmp_ro_km2.tif -o  runoff/cmp_ro_km2.tif 
rm -f /dev/shm/cmp_ro_km2.tif

# change pixel resolution of the runoff 
gdalwarp  -s_srs EPSG:4326   -t_srs EPSG:4326   -ot Float32  -co COMPRESS=DEFLATE -co ZLEVEL=9  -overwrite  -tr 0.0083333333333333333333  0.0083333333333333333333   -srcnodata -9999  -dstnodata  -9999 -r bilinear   runoff/cmp_ro_km2.tif     runoff/cmp_ro_1km.tif 

# convert uM to mgN
# i should do uM/1000 * 14 and I will get mgN/L 
oft-calc -ot Float32    NO3_TN/map_pred_TN.tif  /dev/shm/map_pred_TN_mg-l.tif    <<EOF
1
#1 1000 / 14 *
EOF

# impose sea mask -1
pksetmask -ot Float32 -co COMPRESS=DEFLATE -co ZLEVEL=9 -m  NO3_TN/map_pred_TN.tif -msknodata -1  -p '=' -nodata -1 -i /dev/shm/map_pred_TN_mg-l.tif -o  NO3_TN/map_pred_TN_mg-l.tif 
rm /dev/shm/map_pred_TN_mg-l.tif

gdalbuildvrt -allow_projection_difference   -te $(getCorners4Gwarp   NO3_TN/map_pred_TN.tif   )   -overwrite  -separate  /dev/shm/Overall_TN.vrt    NO3_TN/map_pred_TN_mg-l.tif   runoff/cmp_ro_1km.tif /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/GEO_AREA/area_tif/30arc-sec-Area_prj6842.tif

# the 100   convert the mm in dm 
# the 10000 convert the km in dm 

# gdallocationinfo -valonly  /dev/shm/Overall_TN.vrt   22577 1391 
# TN =  3.77106595039368  mg/l
# runoff =  0.0262735132128 mm 
# 570023

oft-calc -ot Float32   /dev/shm/Overall_TN.vrt    /dev/shm/cmp_ro_TN.tif  <<EOF
1
#1 #2 *
EOF

# output mg * liter 

pksetmask  -ot Float32     -co COMPRESS=DEFLATE -co ZLEVEL=9  \
-m  runoff/cmp_ro_1km.tif    -msknodata -9999 -p '='   -nodata -1 \
-m  NO3_TN/map_pred_TN.tif   -msknodata -1  -p '='     -nodata -1 \
-m  /dev/shm/cmp_ro_TN.tif   -msknodata  0  -p '<'     -nodata -1    -i   /dev/shm/cmp_ro_TN.tif  -o  NO3_TN/cmp_ro_TN.tif


find  /tmp/     -user $USER   2>/dev/null  | xargs -n 1 -P 1 rm -ifr  
find  /dev/shm  -user $USER   2>/dev/null  | xargs -n 1 -P 1 rm -ifr  



