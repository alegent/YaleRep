# calculate pearson cofficent between the EARTHENV-DEM90 and GMTED2010 derived topographic variables
# be	Breakline Emphasis     
# ds	Systematic Subsample   
# md	Median Statistic       
# mi	Minimum Statistic      
# mn	Mean Statistic         
# mx	Maximum Statistic      
# sd	Standard Dev. Statistic

gdal_translate  -projwin  $(getCorners4Gtranslate GMTED2010/roughness/median/tiles/5_1_be.tif) resol_x10/roughness/median/roughness_median.tif resol_x10/roughness/median/roughness_median-clip.tif

gdal_merge.py  -separate  -o 5_1_be_merge.tif   5_1_be.tif /mnt/data2/dem_variables/resol_x10/roughness/median/roughness_median-clip.tif
gdal_merge.py  -separate  -o 5_1_ds_merge.tif   5_1_ds.tif /mnt/data2/dem_variables/resol_x10/roughness/median/roughness_median-clip.tif
gdal_merge.py  -separate  -o 5_1_md_merge.tif   5_1_md.tif /mnt/data2/dem_variables/resol_x10/roughness/median/roughness_median-clip.tif
gdal_merge.py  -separate  -o 5_1_mn_merge.tif   5_1_mn.tif /mnt/data2/dem_variables/resol_x10/roughness/median/roughness_median-clip.tif

oft-pearson.bash 5_1_be_merge.tif 5_1_be_merge.txt
oft-pearson.bash 5_1_ds_merge.tif 5_1_ds_merge.txt
oft-pearson.bash 5_1_md_merge.tif 5_1_md_merge.txt
oft-pearson.bash 5_1_mn_merge.tif 5_1_mn_merge.txt

# results 
# GMTED2010 -  250 EARTHENV-DEM90 – 90m 
# 1km-median (Roughness of Systematic Subsample ) 1km-median (Roughness of  -DEM90)  0.989316
# 1km-median (Roughness of Median Statistic)      1km-median (Roughness of  -DEM90)  0.988585
# 1km-median (Roughness of Mean Statistic)        1km-median (Roughness of  -DEM90)  0.987848
# 1km-median (Roughness of Breakline Emphasis )   1km-median (Roughness of  -DEM90)  0.982874


cd /mnt/data2/dem_variables/GMTED2010/tpi/median/tiles

gdal_translate -projwin $(getCorners4Gtranslate /mnt/data2/dem_variables/GMTED2010/tpi/median/tiles/5_1_be.tif) /mnt/data2/dem_variables/resol_x10/tpi/median/tpi_median.tif /mnt/data2/dem_variables/resol_x10/tpi/median/tpi_median-clip.tif

gdal_merge.py  -separate  -o 5_1_be_merge.tif   5_1_be.tif /mnt/data2/dem_variables/resol_x10/tpi/median/tpi_median-clip.tif
gdal_merge.py  -separate  -o 5_1_ds_merge.tif   5_1_ds.tif /mnt/data2/dem_variables/resol_x10/tpi/median/tpi_median-clip.tif
gdal_merge.py  -separate  -o 5_1_md_merge.tif   5_1_md.tif /mnt/data2/dem_variables/resol_x10/tpi/median/tpi_median-clip.tif
gdal_merge.py  -separate  -o 5_1_mn_merge.tif   5_1_mn.tif /mnt/data2/dem_variables/resol_x10/tpi/median/tpi_median-clip.tif

oft-pearson.bash 5_1_be_merge.tif 5_1_be_merge.txt
oft-pearson.bash 5_1_ds_merge.tif 5_1_ds_merge.txt
oft-pearson.bash 5_1_md_merge.tif 5_1_md_merge.txt
oft-pearson.bash 5_1_mn_merge.tif 5_1_mn_merge.txt

# results 
# GMTED2010 -  250 EARTHENV-DEM90 – 90m

# 1km-median (tpi of Median Statistic)      1km-median (tpi of  -DEM90)   0.798472
# 1km-median (tpi of Mean Statistic)        1km-median (tpi of  -DEM90)   0.793509
# 1km-median (tpi of Systematic Subsample ) 1km-median (tpi of  -DEM90)   0.792891
# 1km-median (tpi of Breakline Emphasis )   1km-median (tpi of  -DEM90)   0.639219

cd /mnt/data2/dem_variables/GMTED2010/tri/median/tiles
gdal_translate -projwin $(getCorners4Gtranslate /mnt/data2/dem_variables/GMTED2010/tri/median/tiles/5_1_be.tif) /mnt/data2/dem_variables/resol_x10/tri/median/tri_median.tif /mnt/data2/dem_variables/resol_x10/tri/median/tri_median-clip.tif

gdal_merge.py  -separate  -o 5_1_be_merge.tif   5_1_be.tif /mnt/data2/dem_variables/resol_x10/tri/median/tri_median-clip.tif
gdal_merge.py  -separate  -o 5_1_ds_merge.tif   5_1_ds.tif /mnt/data2/dem_variables/resol_x10/tri/median/tri_median-clip.tif
gdal_merge.py  -separate  -o 5_1_md_merge.tif   5_1_md.tif /mnt/data2/dem_variables/resol_x10/tri/median/tri_median-clip.tif
gdal_merge.py  -separate  -o 5_1_mn_merge.tif   5_1_mn.tif /mnt/data2/dem_variables/resol_x10/tri/median/tri_median-clip.tif

oft-pearson.bash 5_1_be_merge.tif 5_1_be_merge.txt
oft-pearson.bash 5_1_ds_merge.tif 5_1_ds_merge.txt
oft-pearson.bash 5_1_md_merge.tif 5_1_md_merge.txt
oft-pearson.bash 5_1_mn_merge.tif 5_1_mn_merge.txt

# results 
# GMTED2010 -  250 EARTHENV-DEM90 – 90m 
# 1km-median (tri of Median Statistic)      1km-median (tri of  -DEM90)  0.990189
# 1km-median (tri of Systematic Subsample ) 1km-median (tri of  -DEM90)  0.990139
# 1km-median (tri of Mean Statistic)        1km-median (tri of  -DEM90)  0.989568
# 1km-median (tri of Breakline Emphasis )   1km-median (tri of  -DEM90)  0.98115


# therefore the GMTED2010  Median Statistic is consider the one that better capture the altitude  variation to derive topographic variables  