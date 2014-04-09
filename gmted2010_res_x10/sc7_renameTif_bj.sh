

module load Tools/Python/2.7.3
module load Libraries/GDAL/1.10.0
module load Tools/PKTOOLS/2.4.2
module load Libraries/OSGEO/1.10.0

cd /lustre0/scratch/ga254/dem_bj/GMTED2010

mv altitude/max_of_mx/altitude_max_of_mx_md.tif        altitude/max_of_mx/elevation_mx_GMTED2010_mx.tif
mv altitude/mean_of_mn/altitude_mean_of_mn_md.tif      altitude/mean_of_mn/elevation_mn_GMTED2010_mn.tif
mv altitude/median_of_md/altitude_median_of_md_md.tif  altitude/median_of_md/elevation_md_GMTED2010_md.tif 
mv altitude/min_of_mi/altitude_min_of_mi_md.tif        altitude/min_of_mi/elevation_mi_GMTED2010_mi.tif
mv altitude/stdev_of_mn/altitude_stdev_of_mn_md.tif    altitude/stdev_of_mn/elevation_sd_GMTED2010_mn.tif

# aspect cos 


Offset: 0,   Scale:0.0001

mv  aspect/max/aspect_max_md__cos_t10k.tif             aspect/max/aspect-cosine_mx_GMTED2010_md.tif
gdal_edit.py -mo "Offset: 0,   Scale:0.0001"   aspect/max/aspect-cosine_mx_GMTED2010_md.tif
mv  aspect/max/aspect_max_md__sin_t10k.tif             aspect/max/aspect-sine_mx_GMTED2010_md.tif
gdal_edit.py -mo "Offset: 0,   Scale:0.0001"   aspect/max/aspect-sine_mx_GMTED2010_md.tif

mv  aspect/min/aspect_min_md__cos_t10k.tif             aspect/min/aspect-cosine_mi_GMTED2010_md.tif
gdal_edit.py -mo "Offset: 0,   Scale:0.0001"   aspect/min/aspect-cosine_mi_GMTED2010_md.tif
mv  aspect/min/aspect_min_md__sin_t10k.tif             aspect/min/aspect-sine_mi_GMTED2010_md.tif
gdal_edit.py -mo "Offset: 0,   Scale:0.0001"   aspect/min/aspect-sine_mi_GMTED2010_md.tif

mv  aspect/mean/aspect_mean_md__cos_t10k.tif             aspect/mean/aspect-cosine_mn_GMTED2010_md.tif
gdal_edit.py -mo "Offset: 0,   Scale:0.0001"   aspect/mean/aspect-cosine_mn_GMTED2010_md.tif
mv  aspect/mean/aspect_mean_md__sin_t10k.tif             aspect/mean/aspect-sine_mn_GMTED2010_md.tif
gdal_edit.py -mo "Offset: 0,   Scale:0.0001"   aspect/mean/aspect-sine_mn_GMTED2010_md.tif

mv  aspect/median/aspect_median_md__cos_t10k.tif             aspect/median/aspect-cosine_md_GMTED2010_md.tif
gdal_edit.py -mo "Offset: 0,   Scale:0.0001"   aspect/median/aspect-cosine_md_GMTED2010_md.tif
mv  aspect/median/aspect_median_md__sin_t10k.tif             aspect/median/aspect-sine_md_GMTED2010_md.tif
gdal_edit.py -mo "Offset: 0,   Scale:0.0001"   aspect/median/aspect-sine_md_GMTED2010_md.tif

mv  aspect/stdev/aspect_stdev_md__cos_t10k.tif             aspect/stdev/aspect-cosine_sd_GMTED2010_md.tif
gdal_edit.py -mo "Offset: 0,   Scale:0.0001"   aspect/stdev/aspect-cosine_sd_GMTED2010_md.tif
mv  aspect/stdev/aspect_stdev_md__sin_t10k.tif             aspect/stdev/aspect-sine_sd_GMTED2010_md.tif
gdal_edit.py -mo "Offset: 0,   Scale:0.0001"   aspect/stdev/aspect-sine_sd_GMTED2010_md.tif

# eastness and northness 

mv  aspect/max/aspect_max_md__Ew_t10k.tif              aspect/max/eastness_mx_GMTED2010_md.tif  
gdal_edit.py -mo "Offset: 0,   Scale:0.0001"   aspect/max/eastness_mx_GMTED2010_md.tif
mv  aspect/max/aspect_max_md__Nw_t10k.tif              aspect/max/northness_mx_GMTED2010_md.tif
gdal_edit.py -mo "Offset: 0,   Scale:0.0001"   aspect/max/northness_mx_GMTED2010_md.tif

mv  aspect/min/aspect_min_md__Ew_t10k.tif              aspect/min/eastness_mi_GMTED2010_md.tif
gdal_edit.py -mo "Offset: 0,   Scale:0.0001"   aspect/min/eastness_mi_GMTED2010_md.tif
mv  aspect/min/aspect_min_md__Nw_t10k.tif              aspect/min/northness_mi_GMTED2010_md.tif
gdal_edit.py -mo "Offset: 0,   Scale:0.0001"   aspect/min/northness_mi_GMTED2010_md.tif

mv  aspect/mean/aspect_mean_md__Ew_t10k.tif            aspect/mean/eastness_mn_GMTED2010_md.tif
gdal_edit.py -mo "Offset: 0,   Scale:0.0001"   aspect/mean/eastness_mn_GMTED2010_md.tif
mv  aspect/mean/aspect_mean_md__Nw_t10k.tif            aspect/mean/northness_mn_GMTED2010_md.tif
gdal_edit.py -mo "Offset: 0,   Scale:0.0001"   aspect/mean/northness_mn_GMTED2010_md.tif

mv  aspect/median/aspect_median_md__Ew_t10k.tif        aspect/median/eastness_md_GMTED2010_md.tif
gdal_edit.py -mo "Offset: 0,   Scale:0.0001"   aspect/median/eastness_md_GMTED2010_md.tif
mv  aspect/median/aspect_median_md__Nw_t10k.tif        aspect/median/northness_md_GMTED2010_md.tif
gdal_edit.py -mo "Offset: 0,   Scale:0.0001"   aspect/median/northness_md_GMTED2010_md.tif

mv  aspect/stdev/aspect_stdev_md__Ew_t10k.tif          aspect/stdev/eastness_sd_GMTED2010_md.tif
gdal_edit.py -mo "Offset: 0,   Scale:0.0001"   aspect/stdev/eastness_sd_GMTED2010_md.tif
mv  aspect/stdev/aspect_stdev_md__Nw_t10k.tif          aspect/stdev/northness_sd_GMTED2010_md.tif
gdal_edit.py -mo "Offset: 0,   Scale:0.0001"   aspect/stdev/northness_sd_GMTED2010_md.tif


# roughness


mv roughness/max/roughness_max_md.tif        roughness/max/roughness_mx_GMTED2010_md.tif
mv roughness/min/roughness_min_md.tif        roughness/max/roughness_mi_GMTED2010_md.tif
mv roughness/mean/roughness_mean_md.tif      roughness/max/roughness_mn_GMTED2010_md.tif
mv roughness/median/roughness_median_md.tif  roughness/max/roughness_md_GMTED2010_md.tif
mv roughness/stdev/roughness_stdev_md.tif    roughness/max/roughness_sd_GMTED2010_md.tif

# slope 

mv slope/max/slope_max_md.tif        slope/max/slope_mx_GMTED2010_md.tif
mv slope/min/slope_min_md.tif        slope/max/slope_mi_GMTED2010_md.tif
mv slope/mean/slope_mean_md.tif      slope/max/slope_mn_GMTED2010_md.tif
mv slope/median/slope_median_md.tif  slope/max/slope_md_GMTED2010_md.tif
mv slope/stdev/slope_stdev_md.tif    slope/max/slope_sd_GMTED2010_md.tif

# tpi 

mv tpi/max/tpi_max_md.tif        tpi/max/tpi_mx_GMTED2010_md.tif
gdal_edit.py -mo "Offset: 0,   Scale:0.1" tpi/max/tpi_mx_GMTED2010_md.tif
mv tpi/min/tpi_min_md.tif        tpi/max/tpi_mi_GMTED2010_md.tif
gdal_edit.py -mo "Offset: 0,   Scale:0.1" tpi/max/tpi_mi_GMTED2010_md.tif
mv tpi/mean/tpi_mean_md.tif      tpi/max/tpi_mn_GMTED2010_md.tif
gdal_edit.py -mo "Offset: 0,   Scale:0.1" tpi/max/tpi_mn_GMTED2010_md.tif
mv tpi/median/tpi_median_md.tif  tpi/max/tpi_md_GMTED2010_md.tif
gdal_edit.py -mo "Offset: 0,   Scale:0.1" tpi/max/tpi_md_GMTED2010_md.tif
mv tpi/stdev/tpi_stdev_md.tif    tpi/max/tpi_sd_GMTED2010_md.tif
gdal_edit.py -mo "Offset: 0,   Scale:0.1" tpi/max/tpi_sd_GMTED2010_md.tif

# tri

mv tri/max/tri_max_md.tif        tri/max/tri_mx_GMTED2010_md.tif
mv tri/min/tri_min_md.tif        tri/max/tri_mi_GMTED2010_md.tif
mv tri/mean/tri_mean_md.tif      tri/max/tri_mn_GMTED2010_md.tif
mv tri/median/tri_median_md.tif  tri/max/tri_md_GMTED2010_md.tif
mv tri/stdev/tri_stdev_md.tif    tri/max/tri_sd_GMTED2010_md.tif



# sent to litoria 

scp /lustre0/scratch/ga254/dem_bj/GMTED2010/altitude/{m,s}*/[a-z]*.tif giuseppea@litoria.eeb.yale.edu:/mnt/data/jetzlab/Data/environ/global/dem_variables/GMTED2010/altitude_v2/

for dir1  in aspect slope tri tpi roughness aspect ; do   scp /lustre0/scratch/ga254/dem_bj/GMTED2010/$dir1/[a-s]*/*.tif  giuseppea@litoria.eeb.yale.edu:/mnt/data/jetzlab/Data/environ/global/dem_variables/GMTED2010/$dir1"_v2" ; done
