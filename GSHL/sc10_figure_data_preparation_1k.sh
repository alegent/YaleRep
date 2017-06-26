#!/bin/bash
#SBATCH -p scavenge
#SBATCH -J sc10_figure_data_preparation_1k.sh
#SBATCH -n 1 -c 1 -N 1  
#SBATCH -t 24:00:00
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc10_figure_data_preparation_1k.sh.%J.out  
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc10_figure_data_preparation_1k.sh.%J.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email

# sbatch   /gpfs/home/fas/sbsc/ga254/scripts/GSHL/sc10_figure_data_preparation_1k.sh


DIR=/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/GSHL

# figure a  bin and core 

gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin  -91.5 40 -89 37  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84.tif  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84.tif

gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin  -91.5 40 -89 37  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin_ct.tif $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin_ct.tif

gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin  -91.5 40 -89 37  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core.tif $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core.tif

rm -fr  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core.{shp,prj,shx,dbf}
gdal_polygonize.py -f "ESRI Shapefile" $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core.tif $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_core.shp

# figure b  cost and core 

gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin  -91.5 40 -89 37  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_watershad/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_cost.tif  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_cost.tif 

# figure c watershed 
rm $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_ws_clump_msk_clump.*
ogr2ogr -skipfailures  -clipdst -91.5 37 -89 40 $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_ws_clump_msk_clump.shp  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_watershad/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_ws_clump_msk_clump.shp  

# figure d watershed and bin 

gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin  -91.5 40 -89 37  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_watershad/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_ws_clump_msk_clump_bin.tif    $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_ws_clump_msk_clump_bin.tif

ogr2ogr -skipfailures  -clipdst -91.5 37 -89 40 $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_ws_clump_msk_clump_bin.shp  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_watershad/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_ws_clump_msk_clump_bin.shp  


gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin  -91.5 40 -89 37  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin5_clump.tif   $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin5_clump.tif

rm -f $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin5_clump.{shp,prj,shx,dbf}
gdal_polygonize.py -f "ESRI Shapefile" $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin5_clump.tif $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin5_clump.shp 

gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin  -91.5 40 -89 37  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin4_clump.tif   $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin4_clump.tif

rm -f $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin4_clump.{shp,prj,shx,dbf}
gdal_polygonize.py -f "ESRI Shapefile" $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin4_clump.tif $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin4_clump.shp 


gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin  -91.5 40 -89 37  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin6_clump.tif   $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin6_clump.tif

rm -f $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin6_clump.{shp,prj,shx,dbf}
gdal_polygonize.py -f "ESRI Shapefile" $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin6_clump.tif $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin6_clump.shp 


gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin  -91.5 40 -89 37  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_bin/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin7_clump.tif   $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin7_clump.tif

rm -f $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin7_clump.{shp,prj,shx,dbf}
gdal_polygonize.py -f "ESRI Shapefile" $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin7_clump.tif $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin7_clump.shp 


# data aggregation 


gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin  -91.5 40 -89 37  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_lst/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_ws_clump_msk_clump_bin_LST_MOYDmax_Day_spline_month7mean.tif  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_ws_clump_msk_clump_bin_LST_MOYDmax_Day_spline_month7mean.tif 
gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin  -91.5 40 -89 37  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_lst/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin9_buf_clump_LST_MOYDmax_Day_spline_month7mean.tif    $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin9_buf_clump_LST_MOYDmax_Day_spline_month7mean.tif

gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin  -91.5 40 -89 37  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_lst/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin9_buf_clump_LST_MOYDmax_Day_spline_month7stdev.tif    $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin9_buf_clump_LST_MOYDmax_Day_spline_month7stdev.tif

gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin  -91.5 40 -89 37 $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_lst/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_ws_clump_msk_clump_bin_LST_MOYDmax_Day_spline_month7mean_mskbuf.tif  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_ws_clump_msk_clump_bin_LST_MOYDmax_Day_spline_month7mean_mskbuf.tif

gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin  -91.5 40 -89 37 $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_lst/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_ws_clump_msk_clump_bin_LST_MOYDmax_Day_spline_month7stdev_mskbuf.tif  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_ws_clump_msk_clump_bin_LST_MOYDmax_Day_spline_month7stdev_mskbuf.tif


# data_aggregation for 2 big city 


gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin  -1.25 52.5 0.8 50.7  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_lst/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin9_buf_clump_LST_MOYDmax_Day_spline_month7mean.tif    $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/buff_LST_MOYDmax_Day_spline_month7mean_london.tif

gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin   -1.25 52.5 0.8 50.7  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_lst/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin9_buf_clump_LST_MOYDmax_Day_spline_month7stdev.tif    $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/buff_LST_MOYDmax_Day_spline_month7stdev_london.tif

gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin  -1.25 52.5 0.8 50.7  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_lst/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_ws_clump_msk_clump_bin_LST_MOYDmax_Day_spline_month7mean_mskbuf.tif  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/compunit_LSTmean_mskbuf_london.tif

gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin  -1.25 52.5 0.8 50.7  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_lst/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_ws_clump_msk_clump_bin_LST_MOYDmax_Day_spline_month7stdev_mskbuf.tif  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/compunit_LSTstdev_mskbuf_london.tif

gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin 1.41 50 3.4 48 $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_lst/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin9_buf_clump_LST_MOYDmax_Day_spline_month7mean.tif    $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/buff_LST_MOYDmax_Day_spline_month7mean_paris.tif

gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin 1.41 50 3.4 48  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_lst/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_bin9_buf_clump_LST_MOYDmax_Day_spline_month7stdev.tif    $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/buff_LST_MOYDmax_Day_spline_month7stdev_paris.tif

gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin 1.41 50 3.4 48  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_lst/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_ws_clump_msk_clump_bin_LST_MOYDmax_Day_spline_month7mean_mskbuf.tif  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/compunit_LSTmean_mskbuf_paris.tif

gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin 1.41 50 3.4 48  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_lst/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_WGS84_ws_clump_msk_clump_bin_LST_MOYDmax_Day_spline_month7stdev_mskbuf.tif  $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/compunit_LSTstdev_mskbuf_paris.tif

gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin  -1.25 52.5 0.8 50.7  /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/MYOD11A2_celsiusmean/LST_MOYDmax_Day_spline_month7.tif   $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/LST_MOYDmax_Day_spline_month7_london.tif
gdal_translate -co COMPRESS=DEFLATE -co ZLEVEL=9  -projwin   1.41 50 3.4 48 /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/MYOD11A2_celsiusmean/LST_MOYDmax_Day_spline_month7.tif   $DIR/GHS_BUILT_LDS2014_GLOBE_R2016A_54009_1k_v1_0_figure/LST_MOYDmax_Day_spline_month7_paris.tif
