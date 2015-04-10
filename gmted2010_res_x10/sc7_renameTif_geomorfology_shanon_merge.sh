
cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geomorphon/

mv geomorphon/count/geomorphon_count.tif  geomorphon/count/geomorphic_count_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Geomorphic count" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds  Geomorphic class count derived from GMTED2010 Medium Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4 & GRASS 7.0 r.geomorphon " \
-a_ullr  -180 +84  +180 -56 \
geomorphon/count/geomorphic_count_GMTED2010_md.tif

mv geomorphon/majority/geomorphon_majority.tif  geomorphon/majority/geomorphic_mode_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Geomorphic mode/majority" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds  Geomorphic class mode/majority derived from GMTED2010 Medium Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4 & GRASS 7.0 r.geomorphon " \
-a_ullr  -180 +84  +180 -56 \
geomorphon/majority/geomorphic_mode_GMTED2010_md.tif

gdal_calc.py  --overwrite   --type=UInt16  --creation-option=COMPRESS=LZW  --creation-option=ZLEVEL=9   -A  geomorphon/shannon/geomorphon_shannon.tif     --calc="( A * 1000 )"  --outfile=geomorphon/shannon/geomorphic_shannon_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Geomorphic Shannon index" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds  Geomorphic class Shannon index derived from GMTED2010 Medium Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4 & GRASS 7.0 r.geomorphon " \
-mo "Offset: 0,   Scale:0.0001" \
-a_ullr  -180 +84  +180 -56 \
geomorphon/shannon/geomorphic_shannon_GMTED2010_md.tif


cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geomorphon/percent

# the reclass process is not perfect there few pixel on the border that are not correct 

seq 1 10 | xargs -n 1 -P 10 bash -c $'  

CLASS=$1

gdalbuildvrt -overwrite   geomorphon_percent_class$CLASS.vrt  geomorphon_percent_class$CLASS.tif 
head  -6  geomorphon_percent_class$CLASS.vrt  >   geomorphon_percent_class$CLASS.vrt-tmp
echo  "<ColorInterp>Grey</ColorInterp>"       >>  geomorphon_percent_class$CLASS.vrt-tmp
tail -10  geomorphon_percent_class$CLASS.vrt  >>  geomorphon_percent_class$CLASS.vrt-tmp

gdal_translate   -co COMPRESS=LZW -co ZLEVEL=9  geomorphon_percent_class$CLASS.vrt-tmp  geomorphon_percent_class$CLASS.tif-tmp

pkreclass -ot UInt16 -of GeoTIFF   -co COMPRESS=LZW -co ZLEVEL=9   -code  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/geomorphon/percent/reclass.txt  -i  geomorphon_percent_class$CLASS.tif-tmp  -o  geomorphic_class${CLASS}_GMTED2010_md.tif
gdal_edit.py \
-mo "TIFFTAG_ARTIST=Giuseppe Amatulli (giuseppe.amatulli@yale.edu , giuseppe.amatulli@gmail.com)" \
-mo "TIFFTAG_DATETIME=2014" \
-mo "TIFFTAG_DOCUMENTNAME=30 arc-seconds Geomorphic percent" \
-mo "TIFFTAG_IMAGEDESCRIPTION=30 arc-seconds  Geomorphic class percent derived from GMTED2010 Medium Statistic, 7.5 arc-seconds prduct" \
-mo "TIFFTAG_SOFTWARE=gdal 1.10.0 & pktools 2.5.2 & Open Foris Geospatial Toolkit 1.25.4 & GRASS 7.0 r.geomorphon " \
-mo "Offset: 0,   Scale:0.01" \
-a_ullr  -180 +84  +180 -56 \
geomorphic_class${CLASS}_GMTED2010_md.tif
rm -f  geomorphon_percent_class$CLASS.vrt-tmp  geomorphon_percent_class$CLASS.tif-tmp
' _ 






# sent to litoria 

scp /lustre0/scratch/ga254/dem_bj/GMTED2010/altitude/{m,s}*/[a-z]*.tif giuseppea@litoria.eeb.yale.edu:/mnt/data/jetzlab/Data/environ/global/dem_variables/GMTED2010/altitude_v2/

for dir1  in aspect slope tri tpi roughness aspect ; do   scp /lustre0/scratch/ga254/dem_bj/GMTED2010/$dir1/[a-s]*/*.tif  giuseppea@litoria.eeb.yale.edu:  /mnt/data2/scratch/GMTED2010_ga/top_variables/  ; done

