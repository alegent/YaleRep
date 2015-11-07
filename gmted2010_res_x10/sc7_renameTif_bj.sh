cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9  altitude/max_of_mx/altitude_max_of_mx.tif        altitude/max_of_mx/elevation_mx_GMTED2010_mx.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Maximum elevation" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Maximum elevation derived from GMTED2010 Maximum Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
altitude/max_of_mx/elevation_mx_GMTED2010_mx.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9  altitude/mean_of_mn/altitude_mean_of_mn.tif      altitude/mean_of_mn/elevation_mn_GMTED2010_mn.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Mean elevation" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Mean elevation derived from GMTED2010 Mean Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
altitude/mean_of_mn/elevation_mn_GMTED2010_mn.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9  altitude/median_of_md/altitude_median_of_md.tif  altitude/median_of_md/elevation_md_GMTED2010_md.tif 
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Median elevation" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Median elevation derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
altitude/median_of_md/elevation_md_GMTED2010_md.tif 

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   altitude/min_of_mi/altitude_min_of_mi.tif        altitude/min_of_mi/elevation_mi_GMTED2010_mi.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Minimum elevation" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Minimum elevation derived from GMTED2010 Minimum Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
altitude/min_of_mi/elevation_mi_GMTED2010_mi.tif


gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9  altitude/stdev_of_mn/altitude_stdev_of_mn.tif    altitude/stdev_of_mn/elevation_sd_GMTED2010_mn.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Standard Deviation elevation" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Standard Deviation elevation derived from GMTED2010 Mean Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
altitude/stdev_of_mn/elevation_sd_GMTED2010_mn.tif

# aspect cos and sine 

# Offset: 0,   Scale:1
gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   aspect/max/aspect_max_md_cos.tif             aspect/max/aspect-cosine_mx_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Maximum Aspect-Cosine" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Maximum Aspect-Cosine derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:1" \
-a_ullr  -180 +84  +180 -56  \
aspect/max/aspect-cosine_mx_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   aspect/max/aspect_max_md_sin.tif             aspect/max/aspect-sine_mx_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Maximum Aspect-Sine" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Maximum Aspect-Sine derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:1" \
-a_ullr  -180 +84  +180 -56  \
aspect/max/aspect-sine_mx_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   aspect/min/aspect_min_md_cos.tif             aspect/min/aspect-cosine_mi_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Minimum Aspect-Cosine" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Minimum Aspect-Cosine derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:1" \
-a_ullr  -180 +84  +180 -56  \
aspect/min/aspect-cosine_mi_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9    aspect/min/aspect_min_md_sin.tif     aspect/min/aspect-sine_mi_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Minimum Aspect-Sine" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Minimum Aspect-Sine derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:1" \
-a_ullr  -180 +84  +180 -56  \
aspect/min/aspect-sine_mi_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   aspect/mean/aspect_mean_md_cos.tif    aspect/mean/aspect-cosine_mn_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Mean Aspect-Cosine" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Mean Aspect-Cosine derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:1" \
-a_ullr  -180 +84  +180 -56  \
aspect/mean/aspect-cosine_mn_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   aspect/mean/aspect_mean_md_sin.tif             aspect/mean/aspect-sine_mn_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Mean Aspect-Sine" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Mean Aspect-Sine derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:1" \
-a_ullr  -180 +84  +180 -56  \
aspect/mean/aspect-sine_mn_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   aspect/median/aspect_median_md_cos.tif  aspect/median/aspect-cosine_md_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Median Aspect-Cosine" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Median Aspect-Cosine derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:1" \
-a_ullr  -180 +84  +180 -56  \
aspect/median/aspect-cosine_md_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   aspect/median/aspect_median_md_sin.tif             aspect/median/aspect-sine_md_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Median Aspect-Sine" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Median Aspect-Sine derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:1" \
-a_ullr  -180 +84  +180 -56  \
aspect/median/aspect-sine_md_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   aspect/stdev/aspect_stdev_md_cos.tif             aspect/stdev/aspect-cosine_sd_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Standard Deviation Aspect-Cosine" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Standard Deviation Aspect-Cosine derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:1" \
-a_ullr  -180 +84  +180 -56  \
aspect/stdev/aspect-cosine_sd_GMTED2010_md.tif


gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   aspect/stdev/aspect_stdev_md_sin.tif    aspect/stdev/aspect-sine_sd_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Standard Deviation Aspect-Sine" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Standard Deviation Aspect-Sine derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:1" \
-a_ullr  -180 +84  +180 -56  \
aspect/stdev/aspect-sine_sd_GMTED2010_md.tif

# eastness and northness 

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   aspect/max/aspect_max_md_Ew.tif  aspect/max/eastness_mx_GMTED2010_md.tif  
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Maximum Eastness" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Maximum Eastness derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:1" \
-a_ullr  -180 +84  +180 -56  \
aspect/max/eastness_mx_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9    aspect/max/aspect_max_md_Nw.tif              aspect/max/northness_mx_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Maximum Northness" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Maximum Northness derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:1" \
-a_ullr  -180 +84  +180 -56  \
aspect/max/northness_mx_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9    aspect/min/aspect_min_md_Ew.tif              aspect/min/eastness_mi_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Minimum Eastness" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Minimum Eestness derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:1" \
-a_ullr  -180 +84  +180 -56  \
aspect/min/eastness_mi_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9    aspect/min/aspect_min_md_Nw.tif              aspect/min/northness_mi_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Minimum Northness" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Minimum Northness derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:1" \
-a_ullr  -180 +84  +180 -56  \
aspect/min/northness_mi_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9    aspect/mean/aspect_mean_md_Ew.tif            aspect/mean/eastness_mn_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Mean Eastness" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Mean Eestness derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:1" \
-a_ullr  -180 +84  +180 -56  \
aspect/mean/eastness_mn_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9    aspect/mean/aspect_mean_md_Nw.tif            aspect/mean/northness_mn_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Mean Northness" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Mean Northness derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:1" \
-a_ullr  -180 +84  +180 -56  \
aspect/mean/northness_mn_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9    aspect/median/aspect_median_md_Ew.tif        aspect/median/eastness_md_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Median Eastness" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Median Eestness derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:1" \
-a_ullr  -180 +84  +180 -56  \
aspect/median/eastness_md_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9    aspect/median/aspect_median_md_Nw.tif        aspect/median/northness_md_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Median Northness" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Median Northness derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:1" \
-a_ullr  -180 +84  +180 -56  \
aspect/median/northness_md_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9    aspect/stdev/aspect_stdev_md_Ew.tif          aspect/stdev/eastness_sd_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Standard Deviation Eastness" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Standard Deviation Eastness derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:1" \
-a_ullr  -180 +84  +180 -56  \
aspect/stdev/eastness_sd_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9    aspect/stdev/aspect_stdev_md_Nw.tif          aspect/stdev/northness_sd_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Standard Deviation Northness" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Standard Deviation Northness derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:1" \
-a_ullr  -180 +84  +180 -56  \
aspect/stdev/northness_sd_GMTED2010_md.tif


# roughness

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   roughness/max/roughness_max_md.tif        roughness/max/roughness_mx_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Maximum  Roughness" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Maximum Roughness derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
roughness/max/roughness_mx_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   roughness/min/roughness_min_md.tif        roughness/min/roughness_mi_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Minmum  Roughness" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Minimum Roughness derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
 roughness/max/roughness_mi_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   roughness/mean/roughness_mean_md.tif      roughness/mean/roughness_mn_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Mean Roughness" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Mean Roughness derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
 roughness/max/roughness_mn_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   roughness/median/roughness_median_md.tif  roughness/median/roughness_md_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Median  Roughness" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Median Roughness derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
roughness/max/roughness_md_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   roughness/stdev/roughness_stdev_md.tif    roughness/stdev/roughness_sd_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Standard Deviation Roughness" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Standard Deviation Roughness derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
roughness/max/roughness_sd_GMTED2010_md.tif

# slope 

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   slope/max/slope_max_md.tif        slope/max/slope_mx_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Maximum Slope" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Maximum Slope derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
slope/max/slope_mx_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   slope/min/slope_min_md.tif        slope/min/slope_mi_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Minimum Slope" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Minimum Slope derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
slope/max/slope_mi_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   slope/mean/slope_mean_md.tif      slope/mean/slope_mn_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Mean Slope" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Mean Slope derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
slope/max/slope_mn_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   slope/median/slope_median_md.tif  slope/media/slope_md_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Median Slope" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Median Slope derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
slope/max/slope_md_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   slope/stdev/slope_stdev_md.tif    slope/stdev/slope_sd_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Standard Deviation Slope" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Standard Deviation Slope derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
slope/max/slope_sd_GMTED2010_md.tif

# tpi 

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   tpi/max/tpi_max_md.tif        tpi/max/tpi_mx_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Maximum Topographic Position Index" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Maximum Topographic Position Index derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:0.1" \
-a_ullr  -180 +84  +180 -56  \
tpi/max/tpi_mx_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   tpi/min/tpi_min_md.tif        tpi/min/tpi_mi_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Minimum Topographic Position Index" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Minimum Topographic Position Index derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:0.1" \
-a_ullr  -180 +84  +180 -56  \
tpi/max/tpi_mi_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   tpi/mean/tpi_mean_md.tif      tpi/mean/tpi_mn_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Mean Topographic Position Index" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Mean Topographic Position Index derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:0.1" \
-a_ullr  -180 +84  +180 -56  \
tpi/max/tpi_mn_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   tpi/median/tpi_median_md.tif  tpi/median/tpi_md_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Median Topographic Position Index" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Median Topographic Position Index derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:0.1" \
-a_ullr  -180 +84  +180 -56  \
tpi/max/tpi_md_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   tpi/stdev/tpi_stdev_md.tif    tpi/stdev/tpi_sd_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Standard Deviation Topographic Position Index" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Standard Deviation Topographic Position Index derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:0.1" \
-a_ullr  -180 +84  +180 -56  \
tpi/max/tpi_sd_GMTED2010_md.tif

# tri

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   tri/max/tri_max_md.tif        tri/max/tri_mx_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Maximum Terrain Ruggedness Index" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Maximum Terrain Ruggedness Index derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
tri/max/tri_mx_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   tri/min/tri_min_md.tif        tri/min/tri_mi_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Minimum Terrain Ruggedness Index" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Minimum Terrain Ruggedness Index derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
tri/max/tri_mi_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   tri/mean/tri_mean_md.tif      tri/mean/tri_mn_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Mean Terrain Ruggedness Index" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Mean Terrain Ruggedness Index derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
tri/max/tri_mn_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   tri/median/tri_median_md.tif  tri/median/tri_md_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Median Terrain Ruggedness Index" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Median Terrain Ruggedness Index derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
tri/max/tri_md_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   tri/stdev/tri_stdev_md.tif    tri/stdev/tri_sd_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Standard Deviation Terrain Ruggedness Index" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Standard Deviation Terrain Ruggedness Index derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
tri/max/tri_sd_GMTED2010_md.tif

# vrm  Vector Ruggedness Measure

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   vrm/max/vrm_max_md.tif        vrm/max/vrm_mx_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Maximum Vector Ruggedness Measure" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Maximum Vector Ruggedness Measure derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
vrm/max/vrm_mx_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   vrm/min/vrm_min_md.tif        vrm/min/vrm_mi_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Minimum Vector Ruggedness Measure" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Minimum Vector Ruggedness Measure derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
vrm/min/vrm_mi_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   vrm/mean/vrm_mean_md.tif      vrm/mean/vrm_mn_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Mean Vector Ruggedness Measure" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Mean Vector Ruggedness Measure derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
vrm/mean/vrm_mn_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   vrm/median/vrm_median_md.tif  vrm/median/vrm_md_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Median Vector Ruggedness Measure" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Median Vector Ruggedness Measure derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
vrm/median/vrm_md_GMTED2010_md.tif

gdal_translate  -projwin -180 +84  +180 -56  -co COMPRESS=LZW  -co ZLEVEL=9   vrm/stdev/vrm_stdev_md.tif    vrm/stdev/vrm_sd_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2015" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Standard Deviation Vector Ruggedness Measure" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Standard Deviation Vector Ruggedness Measure derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-a_ullr  -180 +84  +180 -56  \
vrm/stdev/vrm_sd_GMTED2010_md.tif


# sent to litoria 

scp /lustre0/scratch/ga254/dem_bj/GMTED2010/altitude/{m,s}*/[a-z]*.tif giuseppea@litoria.eeb.yale.edu:/mnt/data/jetzlab/Data/environ/global/dem_variables/GMTED2010/altitude_v2/

for dir1  in aspect slope tri tpi roughness aspect ; do   scp /lustre0/scratch/ga254/dem_bj/GMTED2010/$dir1/[a-s]*/*.tif  giuseppea@litoria.eeb.yale.edu:  /mnt/data2/scratch/GMTED2010_ga/top_variables/  ; done

ls {aspect,slope,tri,tpi,roughness}/[a-s]*/*GMTED2010*.tif  | xargs -n 1 -P 8 bash -c $'  pkstat -mm  -f  -i  $1   '  _ 

