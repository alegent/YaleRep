

GMTED=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED
SRTM=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/SRTM
TXTGMTED=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/txt
TXTSRTM=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/SRTM/txt


for km in 1 5 10; do 
    for dir1 in elevation tri tpi roughness vrm slope aspect-cosine aspect-sine eastness northness ; do 
	gdal_translate -of XYZ $GMTED/${dir1}_md_GMTED2010_md_km$km.tif $GMTED/txt/${dir1}_md_GMTED2010_md_km$km.txt
    done 
        echo "elevation tri tpi roughness vrm slope aspect-cosine aspect-sine eastness northness" > $TXTGMTED/GMTED_km$km.txt
    paste -d " " <(awk '{ print $3 }' $TXTGMTED/elevation_md_GMTED2010_md_km$km.txt) <(awk '{ print $3 }' $TXTGMTED/tri_md_GMTED2010_md_km$km.txt) <(awk '{ print $3 }' $TXTGMTED/tpi_md_GMTED2010_md_km$km.txt) <(awk '{ print $3 }' $TXTGMTED/roughness_md_GMTED2010_md_km$km.txt) <(awk '{ print $3 }' $TXTGMTED/vrm_md_GMTED2010_md_km$km.txt) <(awk '{ print $3 }' $TXTGMTED/slope_md_GMTED2010_md_km$km.txt) <(awk '{ print $3 }' $TXTGMTED/aspect-cosine_md_GMTED2010_md_km$km.txt)   <(awk '{ print $3 }' $TXTGMTED/aspect-sine_md_GMTED2010_md_km$km.txt) <(awk '{ print $3 }' $TXTGMTED/eastness_md_GMTED2010_md_km$km.txt) <(awk '{ print $3 }' $TXTGMTED/northness_md_GMTED2010_md_km$km.txt) >> $TXTGMTED/GMTED_km$km.txt
done 


for km in 1 5 10; do 
    for dir1 in elevation tri tpi roughness vrm slope aspect-cosine aspect-sine eastness northness ; do 

	if [ $dir1 = "elevation" ]  ; then dir2=elevation_md              ; fi 
	if [ $dir1 = "tri" ]        ; then dir2=tri_median                ; fi 
	if [ $dir1 = "tpi" ]        ; then dir2=tpi_median                ; fi 
	if [ $dir1 = "vrm" ]        ; then dir2=vrm_median                ; fi 
	if [ $dir1 = "slope" ]      ; then dir2=slope_median              ; fi 
	if [ $dir1 = "roughness" ]  ; then dir2=roughness_median          ; fi 

	if [ $dir1 = "aspect-cosine" ] ; then dir2=aspect_cos_median      ; fi 
	if [ $dir1 = "aspect-sine" ]  ; then dir2=aspect_sin_median       ; fi 
	if [ $dir1 = "eastness" ]      ; then dir2=aspect_Ew_median       ; fi 
	if [ $dir1 = "northness" ]     ; then dir2=aspect_Nw_median       ; fi

	gdal_translate -of XYZ $SRTM/${dir2}_SRTM_km$km.tif $SRTM/txt/${dir1}_SRTM_km$km.txt
    done 
        echo "elevation tri tpi roughness vrm slope aspect-cosine aspect-sine eastness northness" > $TXTSRTM/SRTM_km$km.txt
    paste -d " " <(awk '{ print $3 }' $TXTSRTM/elevation_SRTM_km$km.txt) <(awk '{ print $3 }' $TXTSRTM/tri_SRTM_km$km.txt) <(awk '{ print $3 }' $TXTSRTM/tpi_SRTM_km$km.txt) <(awk '{ print $3 }' $TXTSRTM/roughness_SRTM_km$km.txt) <(awk '{ print $3 }' $TXTSRTM/vrm_SRTM_km$km.txt) <(awk '{ print $3 }' $TXTSRTM/slope_SRTM_km$km.txt) <(awk '{ print $3 }' $TXTSRTM/aspect-cosine_SRTM_km$km.txt)   <(awk '{ print $3 }' $TXTSRTM/aspect-sine_SRTM_km$km.txt) <(awk '{ print $3 }' $TXTSRTM/eastness_SRTM_km$km.txt) <(awk '{ print $3 }' $TXTSRTM/northness_SRTM_km$km.txt) >> $TXTSRTM/SRTM_km$km.txt
done 

