export GMTED=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED
export SRTM=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/SRTM
export TXTGMTED=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/txt
export TXTSRTM=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/SRTM/txt

for km in 1 5 10 ; do 
export km=$km 

echo elevation_md_GMTED2010_md_km$km.tif elevation_sd_GMTED2010_md_km$km.tif elevation_psd_GMTED2010_sd_km$km.tif tri_md_GMTED2010_md_km$km.tif tpi_md_GMTED2010_md_km$km.tif roughness_md_GMTED2010_md_km$km.tif vrm_md_GMTED2010_md_km$km.tif slope_md_GMTED2010_md_km$km.tif aspect-cosine_md_GMTED2010_md_km$km.tif aspect-sine_md_GMTED2010_md_km$km.tif eastness_md_GMTED2010_md_km$km.tif northness_md_GMTED2010_md_km$km.tif pcurv_md_GMTED2010_md_km$km.tif tcurv_md_GMTED2010_md_km$km.tif dx_md_GMTED2010_md_km$km.tif dxx_md_GMTED2010_md_km$km.tif dy_md_GMTED2010_md_km$km.tif dyy_md_GMTED2010_md_km$km.tif geomorphic_count_GMTED2010_md_km$km.tif geomorphic_majority_GMTED2010_md_km$km.tif geomorphic_shannon_GMTED2010_md_km$km.tif geomorphic_uni_GMTED2010_md_km$km.tif geomorphic_ent_GMTED2010_md_km$km.tif geomorphic_class1_GMTED2010_md_km$km.tif geomorphic_class2_GMTED2010_md_km$km.tif geomorphic_class3_GMTED2010_md_km$km.tif geomorphic_class4_GMTED2010_md_km$km.tif geomorphic_class5_GMTED2010_md_km$km.tif geomorphic_class6_GMTED2010_md_km$km.tif geomorphic_class7_GMTED2010_md_km$km.tif geomorphic_class8_GMTED2010_md_km$km.tif geomorphic_class9_GMTED2010_md_km$km.tif geomorphic_class10_GMTED2010_md_km$km.tif | xargs -n 1 -P 8 bash -c $' 
dir=$1
name=$(basename $dir .tif) 
gdal_translate -of XYZ $GMTED/alps/${dir} $GMTED/txt/${name}.txt

' _ 

echo "elevation elevationSD elevationPSD tri tpi roughness vrm slope aspect-cosine aspect-sine eastness northness pcurv tcurv dx dxx dy dyy geomorphic_count geomorphic_majority geomorphic_shannon geomorphic_uni geomorphic_ent geomorphic_class1 geomorphic_class2 geomorphic_class3 geomorphic_class4 geomorphic_class5 geomorphic_class6 geomorphic_class7 geomorphic_class8 geomorphic_class9 geomorphic_class10" > $TXTGMTED/GMTED_ALL_km$km.txt
    paste -d " " <(awk '{ print $3 }' $TXTGMTED/elevation_md_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/elevation_sd_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/elevation_psd_GMTED2010_sd_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/tri_md_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/tpi_md_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/roughness_md_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/vrm_md_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/slope_md_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/aspect-cosine_md_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/aspect-sine_md_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/eastness_md_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/northness_md_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/pcurv_md_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/tcurv_md_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/dx_md_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/dxx_md_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/dy_md_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/dyy_md_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/geomorphic_count_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/geomorphic_majority_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/geomorphic_shannon_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/geomorphic_uni_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/geomorphic_ent_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/geomorphic_class1_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/geomorphic_class2_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/geomorphic_class3_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/geomorphic_class4_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/geomorphic_class5_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/geomorphic_class6_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/geomorphic_class7_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/geomorphic_class8_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/geomorphic_class9_GMTED2010_md_km$km.txt) \
                 <(awk '{ print $3 }' $TXTGMTED/geomorphic_class10_GMTED2010_md_km$km.txt)  >> $TXTGMTED/GMTED_ALL_km$km.txt
done 

