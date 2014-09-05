

module load Tools/Python/2.7.3
module load Libraries/GDAL/1.10.0
module load Tools/PKTOOLS/2.4.2
module load Libraries/OSGEO/1.10.0

cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/

mv altitude/max_of_mx/altitude_max_of_mx_md.tif        altitude/max_of_mx/elevation_mx_GMTED2010_mx.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Maximum elevation" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Maximum elevation derived from GMTED2010 Maximum Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
altitude/max_of_mx/elevation_mx_GMTED2010_mx.tif

mv altitude/mean_of_mn/altitude_mean_of_mn_md.tif      altitude/mean_of_mn/elevation_mn_GMTED2010_mn.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Mean elevation" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Mean elevation derived from GMTED2010 Mean Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
altitude/mean_of_mn/elevation_mn_GMTED2010_mn.tif

mv altitude/median_of_md/altitude_median_of_md_md.tif  altitude/median_of_md/elevation_md_GMTED2010_md.tif 
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Median elevation" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Median elevation derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
altitude/median_of_md/elevation_md_GMTED2010_md.tif 

mv altitude/min_of_mi/altitude_min_of_mi_md.tif        altitude/min_of_mi/elevation_mi_GMTED2010_mi.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Minimum elevation" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Minimum elevation derived from GMTED2010 Minimum Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
altitude/min_of_mi/elevation_mi_GMTED2010_mi.tif


mv altitude/stdev_of_mn/altitude_stdev_of_mn_md.tif    altitude/stdev_of_mn/elevation_sd_GMTED2010_mn.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Standard Deviation elevation" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Standard Deviation elevation derived from GMTED2010 Mean Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
altitude/stdev_of_mn/elevation_sd_GMTED2010_mn.tif

# aspect cos 

# Offset: 0,   Scale:0.0001

mv  aspect/max/aspect_max_md__cos_t10k.tif             aspect/max/aspect-cosine_mx_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Maximum Aspect-Cosine" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Maximum Aspect-Cosine derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:0.0001" \
/tmp/aspect-cosine_mx_GMTED2010_md.tif

mv  aspect/max/aspect_max_md__sin_t10k.tif             aspect/max/aspect-sine_mx_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Maximum Aspect-Sine" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Maximum Aspect-Sine derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:0.0001" \
aspect/max/aspect-sine_mx_GMTED2010_md.tif

mv  aspect/min/aspect_min_md__cos_t10k.tif             aspect/min/aspect-cosine_mi_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Minimum Aspect-Cosine" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Minimum Aspect-Cosine derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:0.0001" \
aspect/min/aspect-cosine_mi_GMTED2010_md.tif

mv   aspect/min/aspect_min_md__sin_t10k.tif     aspect/min/aspect-sine_mi_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Minimum Aspect-Sine" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Minimum Aspect-Sine derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:0.0001" \
aspect/min/aspect-sine_mi_GMTED2010_md.tif

mv  aspect/mean/aspect_mean_md__cos_t10k.tif    aspect/mean/aspect-cosine_mn_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Mean Aspect-Cosine" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Mean Aspect-Cosine derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:0.0001" \
aspect/mean/aspect-cosine_mn_GMTED2010_md.tif

mv  aspect/mean/aspect_mean_md__sin_t10k.tif             aspect/mean/aspect-sine_mn_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Mean Aspect-Sine" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Mean Aspect-Sine derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:0.0001" \
aspect/mean/aspect-sine_mn_GMTED2010_md.tif

mv  aspect/median/aspect_median_md__cos_t10k.tif  aspect/median/aspect-cosine_md_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Median Aspect-Cosine" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Median Aspect-Cosine derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:0.0001" \
aspect/median/aspect-cosine_md_GMTED2010_md.tif

mv  aspect/median/aspect_median_md__sin_t10k.tif             aspect/median/aspect-sine_md_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Median Aspect-Sine" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Median Aspect-Sine derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:0.0001" \
aspect/median/aspect-sine_md_GMTED2010_md.tif

mv  aspect/stdev/aspect_stdev_md__cos_t10k.tif             aspect/stdev/aspect-cosine_sd_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Standard Deviation Aspect-Cosine" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Standard Deviation Aspect-Cosine derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:0.0001" \
aspect/stdev/aspect-cosine_sd_GMTED2010_md.tif


mv  aspect/stdev/aspect_stdev_md__sin_t10k.tif    aspect/stdev/aspect-sine_sd_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Standard Deviation Aspect-Sine" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Standard Deviation Aspect-Sine derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:0.0001" \
aspect/stdev/aspect-sine_sd_GMTED2010_md.tif

# eastness and northness 

mv  aspect/max/aspect_max_md__Ew_t10k.tif  aspect/max/eastness_mx_GMTED2010_md.tif  
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Maximum Eastness" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Maximum Eastness derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:0.0001" \
aspect/max/eastness_mx_GMTED2010_md.tif

mv  aspect/max/aspect_max_md__Nw_t10k.tif              aspect/max/northness_mx_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Maximum Northness" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Maximum Northness derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:0.0001" \
aspect/max/northness_mx_GMTED2010_md.tif

mv  aspect/min/aspect_min_md__Ew_t10k.tif              aspect/min/eastness_mi_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Minimum Eastness" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Minimum Eestness derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:0.0001" \
aspect/min/eastness_mi_GMTED2010_md.tif

mv  aspect/min/aspect_min_md__Nw_t10k.tif              aspect/min/northness_mi_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Minimum Northness" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Minimum Northness derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:0.0001" \
aspect/min/northness_mi_GMTED2010_md.tif

mv  aspect/mean/aspect_mean_md__Ew_t10k.tif            aspect/mean/eastness_mn_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Mean Eastness" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Mean Eestness derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:0.0001" \
aspect/mean/eastness_mn_GMTED2010_md.tif

mv  aspect/mean/aspect_mean_md__Nw_t10k.tif            aspect/mean/northness_mn_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Mean Northness" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Mean Northness derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:0.0001" \
aspect/mean/northness_mn_GMTED2010_md.tif

mv  aspect/median/aspect_median_md__Ew_t10k.tif        aspect/median/eastness_md_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Median Eastness" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Median Eestness derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:0.0001" \
aspect/median/eastness_md_GMTED2010_md.tif

mv  aspect/median/aspect_median_md__Nw_t10k.tif        aspect/median/northness_md_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Median Northness" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Median Northness derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:0.0001" \
aspect/median/northness_md_GMTED2010_md.tif

mv  aspect/stdev/aspect_stdev_md__Ew_t10k.tif          aspect/stdev/eastness_sd_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Standard Deviation Eastness" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Standard Deviation Eastness derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:0.0001" \
aspect/stdev/eastness_sd_GMTED2010_md.tif

mv  aspect/stdev/aspect_stdev_md__Nw_t10k.tif          aspect/stdev/northness_sd_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Standard Deviation Northness" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Standard Deviation Northness derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:0.0001" \
aspect/stdev/northness_sd_GMTED2010_md.tif


# roughness

mv roughness/max/roughness_max_md.tif        roughness/max/roughness_mx_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Maximum  Roughness" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Maximum Roughness derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
roughness/max/roughness_mx_GMTED2010_md.tif

mv roughness/min/roughness_min_md.tif        roughness/max/roughness_mi_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Minmum  Roughness" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Minimum Roughness derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
 roughness/max/roughness_mi_GMTED2010_md.tif

mv roughness/mean/roughness_mean_md.tif      roughness/max/roughness_mn_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Mean Roughness" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Mean Roughness derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
 roughness/max/roughness_mn_GMTED2010_md.tif

mv roughness/median/roughness_median_md.tif  roughness/max/roughness_md_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Median  Roughness" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Median Roughness derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
roughness/max/roughness_md_GMTED2010_md.tif

mv roughness/stdev/roughness_stdev_md.tif    roughness/max/roughness_sd_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Standard Deviation Roughness" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Standard Deviation Roughness derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
roughness/max/roughness_sd_GMTED2010_md.tif

# slope 

mv slope/max/slope_max_md.tif        slope/max/slope_mx_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Maximum Slope" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Maximum Slope derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
slope/max/slope_mx_GMTED2010_md.tif

mv slope/min/slope_min_md.tif        slope/max/slope_mi_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Minimum Slope" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Minimum Slope derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
slope/max/slope_mi_GMTED2010_md.tif

mv slope/mean/slope_mean_md.tif      slope/max/slope_mn_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Mean Slope" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Mean Slope derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
slope/max/slope_mn_GMTED2010_md.tif

mv slope/median/slope_median_md.tif  slope/max/slope_md_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Median Slope" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Median Slope derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
slope/max/slope_md_GMTED2010_md.tif

mv slope/stdev/slope_stdev_md.tif    slope/max/slope_sd_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Standard Deviation Slope" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Standard Deviation Slope derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
slope/max/slope_sd_GMTED2010_md.tif

# tpi 

mv tpi/max/tpi_max_md.tif        tpi/max/tpi_mx_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Maximum Topographic Position Index" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Maximum Topographic Position Index derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:0.1" \
tpi/max/tpi_mx_GMTED2010_md.tif

mv tpi/min/tpi_min_md.tif        tpi/max/tpi_mi_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Minimum Topographic Position Index" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Minimum Topographic Position Index derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:0.1" \
tpi/max/tpi_mi_GMTED2010_md.tif

mv tpi/mean/tpi_mean_md.tif      tpi/max/tpi_mn_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Mean Topographic Position Index" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Mean Topographic Position Index derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:0.1" \
tpi/max/tpi_mn_GMTED2010_md.tif

mv tpi/median/tpi_median_md.tif  tpi/max/tpi_md_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Median Topographic Position Index" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Median Topographic Position Index derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:0.1" \
tpi/max/tpi_md_GMTED2010_md.tif

mv tpi/stdev/tpi_stdev_md.tif    tpi/max/tpi_sd_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Standard Deviation Topographic Position Index" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Standard Deviation Topographic Position Index derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
-mo "Offset: 0,   Scale:0.1" \
tpi/max/tpi_sd_GMTED2010_md.tif

# tri

mv tri/max/tri_max_md.tif        tri/max/tri_mx_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Maximum Terrain Ruggedness Index" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Maximum Terrain Ruggedness Index derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
tri/max/tri_mx_GMTED2010_md.tif

mv tri/min/tri_min_md.tif        tri/max/tri_mi_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Minimum Terrain Ruggedness Index" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Minimum Terrain Ruggedness Index derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
tri/max/tri_mi_GMTED2010_md.tif

mv tri/mean/tri_mean_md.tif      tri/max/tri_mn_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Mean Terrain Ruggedness Index" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Mean Terrain Ruggedness Index derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
tri/max/tri_mn_GMTED2010_md.tif

mv tri/median/tri_median_md.tif  tri/max/tri_md_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Median Terrain Ruggedness Index" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Median Terrain Ruggedness Index derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
tri/max/tri_md_GMTED2010_md.tif

mv tri/stdev/tri_stdev_md.tif    tri/max/tri_sd_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Standard Deviation Terrain Ruggedness Index" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds Standard Deviation Terrain Ruggedness Index derived from GMTED2010 Median Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4" \
tri/max/tri_sd_GMTED2010_md.tif


# sent to litoria 

scp /lustre0/scratch/ga254/dem_bj/GMTED2010/altitude/{m,s}*/[a-z]*.tif giuseppea@litoria.eeb.yale.edu:/mnt/data/jetzlab/Data/environ/global/dem_variables/GMTED2010/altitude_v2/

for dir1  in aspect slope tri tpi roughness aspect ; do   scp /lustre0/scratch/ga254/dem_bj/GMTED2010/$dir1/[a-s]*/*.tif  giuseppea@litoria.eeb.yale.edu:  /mnt/data2/scratch/GMTED2010_ga/top_variables/  ; done

