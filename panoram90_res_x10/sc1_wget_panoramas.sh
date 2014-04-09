# get the file list from the ftp 

INDIR=/mnt/data2/dem_variables/dem_panoramas/tiles
cd $INDIR

# wget http://www.viewfinderpanoramas.org/Coverage%20map%20viewfinderpanoramas_org3.htm  

# mv Coverage\ map\ viewfinderpanoramas_org3.htm  $INDIR/../geo_file/list_zip.txt 

# grep "zip"   $INDIR/../geo_file/list_zip.txt  |  awk '{  print $NF }' | awk '{ gsub("href=\"","") ; gsub("\"","")   ; print  }' |  sort -k 1,1 | uniq   >  $INDIR/../geo_file/list_zip_clean.txt 

# cd zip_files

# # the list_zip_clean.txt   contain ANTDEM3 antartich dem so 
# # wget only dem3 lines 

# for file in `grep dem3  $INDIR/../geo_file/list_zip_clean.txt ` ; do echo $file ; done | xargs -n 1 -P 20   wget -m  $1 
# unzip and trasform to tif 

# ls  $INDIR/zip_files/*.zip |   xargs -n 1 -P 14 bash -c  $' 

# file=$1

# # save the standard error and in a file for later use in the loop

# unzip -o  -d /mnt/data2/dem_variables/dem_panoramas/tiles/  $file  &> /mnt/data2/dem_variables/dem_panoramas/tiles/zip_files/listzip$$.txt  

# for f_hgt in $(grep inflating /mnt/data2/dem_variables/dem_panoramas/tiles/zip_files/listzip$$.txt | awk \'{print $2  }\') ; do 

#     f_name_hgt=`basename $f_hgt .hgt`
#     d_name=`dirname $f_hgt`

#     gdal_translate  -co COMPRESS=LZW    $f_hgt   $d_name/$f_name_hgt.tif   
#     rm -f  $f_hgt
# done
 
# rm /mnt/data2/dem_variables/dem_panoramas/tiles/zip_files/listzip$$.txt
# ' _


# in order to restrict the searching path 
# mkdir $INDIR/tilesNE
# mkdir $INDIR/tilesNW
# mkdir $INDIR/tilesSE
# mkdir $INDIR/tilesSW

# mv  $INDIR/*/N*E*.tif $INDIR/tilesNE
# mv  $INDIR/*/N*W*.tif $INDIR/tilesNW
# mv  $INDIR/*/S*E*.tif $INDIR/tilesSE
# mv  $INDIR/*/S*W*.tif $INDIR/tilesSW


# create a vrt filie 

# gdalbuildvrt -overwrite $INDIR/tilesNE/tilesNE.vrt $INDIR/tilesNE/*.tif 
# gdalbuildvrt -overwrite $INDIR/tilesNW/tilesNW.vrt $INDIR/tilesNW/*.tif

# gdalbuildvrt -overwrite $INDIR/tilesSE/tilesSE.vrt $INDIR/tilesSE/*.tif
# gdalbuildvrt -overwrite $INDIR/tilesSW/tilesSW.vrt $INDIR/tilesSW/*.tif

# mkdir /tmp/ramdisk; chmod 777 /tmp/ramdisk
# mount -t tmpfs -o size=10000M tmpfs /tmp/ramdisk

ls /mnt/data2/dem_variables/resol_x10/tif/Smoothed_N*E*.tif |  xargs -n 1 -P 30  bash -c  $'  

file=$1
filename=`basename $file .tif`
gdal_translate  -projwin  $(getCorners4Gtranslate $file) -co COMPRESS=LZW  /mnt/data2/dem_variables/dem_panoramas/tiles/tilesNE/tilesNE.vrt  /tmp/ramdisk/$filename"_tmp.tif"
if [ -f   /tmp/ramdisk/$filename"_tmp.tif"  ]  ; then 
pkreclass -co COMPRESS=LZW -c -32768 -r 0 -i  /tmp/ramdisk/$filename"_tmp.tif"   -o /mnt/data2/dem_variables/dem_panoramas/tiles_merged/$filename.tif
rm -f  /tmp/ramdisk/$filename"_tmp.tif"
fi 

' _



ls /mnt/data2/dem_variables/resol_x10/tif/Smoothed_N*W*.tif |  xargs -n 1 -P 30  bash -c  $'  

file=$1
filename=`basename $file .tif`
gdal_translate  -projwin  $(getCorners4Gtranslate $file) -co COMPRESS=LZW  /mnt/data2/dem_variables/dem_panoramas/tiles/tilesNW/tilesNW.vrt  /tmp/ramdisk/$filename"_tmp.tif"
if [ -f    /tmp/ramdisk/$filename"_tmp.tif"  ]  ; then 
pkreclass -co COMPRESS=LZW -c -32768 -r 0 -i  /tmp/ramdisk/$filename"_tmp.tif"   -o /mnt/data2/dem_variables/dem_panoramas/tiles_merged/$filename.tif
rm -f  /tmp/ramdisk/$filename"_tmp.tif"
fi 

' _

ls /mnt/data2/dem_variables/resol_x10/tif/Smoothed_S*E*.tif |  xargs -n 1 -P 30  bash -c  $'  

file=$1
filename=`basename $file .tif`
gdal_translate  -projwin  $(getCorners4Gtranslate $file) -co COMPRESS=LZW  /mnt/data2/dem_variables/dem_panoramas/tiles/tilesSE/tilesSE.vrt  /tmp/ramdisk/$filename"_tmp.tif"
if [ -f /tmp/ramdisk/$filename"_tmp.tif"  ]  ; then 
pkreclass -co COMPRESS=LZW -c -32768 -r 0 -i  /tmp/ramdisk/$filename"_tmp.tif"   -o /mnt/data2/dem_variables/dem_panoramas/tiles_merged/$filename.tif
rm -f  /tmp/ramdisk/$filename"_tmp.tif"
fi 

' _

ls /mnt/data2/dem_variables/resol_x10/tif/Smoothed_S*W*.tif |  xargs -n 1 -P 30  bash -c  $'  

file=$1
filename=`basename $file .tif`
gdal_translate  -projwin  $(getCorners4Gtranslate $file) -co COMPRESS=LZW  /mnt/data2/dem_variables/dem_panoramas/tiles/tilesSW/tilesSW.vrt  /tmp/ramdisk/$filename"_tmp.tif"
if [ -f   /tmp/ramdisk/$filename"_tmp.tif"  ]  ; then 
pkreclass -co COMPRESS=LZW -c -32768 -r 0 -i  /tmp/ramdisk/$filename"_tmp.tif"   -o /mnt/data2/dem_variables/dem_panoramas/tiles_merged/$filename.tif
rm -f  /tmp/ramdisk/$filename"_tmp.tif"
fi 

' _

