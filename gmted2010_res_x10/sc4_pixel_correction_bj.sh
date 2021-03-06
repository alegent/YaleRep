# correct immage with  anomalus pixel valus. 
# the file

# chek the -mm 

# dir=md75_grd_tif ; ls $dir/?_?.tif | xargs -n 1 -P 25 bash -c $' echo $1 `   gdalinfo  -mm $1  | grep Min | awk \'{ gsub ("[=,]"," ") ; print  $3 ,$4  }\' `    ' _ | sort -g -k 2,2

# giuseppea@turaco:/mnt/data2/dem_variables/GMTED2010/altitude/class_mi$ pkinfo -hist -i   ../../tiles/mi75_grd_tif/5_1.tif  | more 
# -931 1  anomalus 
# -898 1  anomalus
# -498 1
# -461 1

# therefore the -931 -898 will be fill in withe the nearby pixel.

cd /lustre0/scratch/ga254/dem_bj/GMTED2010/tiles/mi75_grd_tif
cp  5_1.tif 5_1_orig.tiff
pkgetmask -co COMPRESS=LZW -i 5_1.tif  -min  -890 -max 10000 -t 1 -f 0 -o 5_1_mask.tif
pkfillnodata -i 5_1.tif  -m 5_1_mask.tif     -o 5_1_fill.tif
mv 5_1_fill.tif 5_1.tif
rm 5_1_mask.tif 

# corretta mx mi non inclusi perche non hanno pixel < di -600

cd /lustre0/scratch/ga254/dem_bj/GMTED2010/tiles/

for dir in  md75_grd_tif be75_grd_tif ds75_grd_tif mn75_grd_tif  ;do 
cd /lustre0/scratch/ga254/dem_bj/GMTED2010/tiles/$dir 
cp  5_1.tif 5_1_orig.tiff
pkgetmask -co COMPRESS=LZW -i 5_1.tif  -min  -600  -max 10000 -t 1 -f 0 -o 5_1_mask.tif
pkfillnodata -i 5_1.tif  -m 5_1_mask.tif     -o 5_1_fill.tif
mv 5_1_fill.tif 5_1.tif
rm 5_1_mask.tif 
done 



# the values becom -93 and -80 

#  -93 2830
#  -93 2831
# 
#  -80 19449
#  -80 19450

## correction of a square box of 500 500 pixel. Set the value = to 179 as the near by pixel......funziona anche con il be75_grd_tif piu grande . 
cd /lustre0/scratch/ga254/dem_bj/GMTED2010/tiles/

for dir in  be75_grd_tif  mi75_grd_tif mn75_grd_tif md75_grd_tif ds75_grd_tif mx75_grd_tif be75_grd_tif  ; do

cd /lustre0/scratch/ga254/dem_bj/GMTED2010/tiles/$dir 
gdal_translate  -srcwin  10070 3830 500 500   2_1.tif  2_1_clip.tif

pksetmask -co COMPRESS=LZW -m 2_1_clip.tif -msknodata  0 -p '='  -nodata 179   -i 2_1.tif      -o 2_1_correct.tif 
gdal_edit.py -a_nodata -32768 2_1_correct.tif 
mv 2_1.tif 2_1_orig.tiff
mv 2_1_correct.tif 2_1.tif 
rm 2_1_clip.tif
done



# correction of a square in the caspian sea set value to -27 
cd /lustre0/scratch/ga254/dem_bj/GMTED2010/tiles/

for dir in mx75_grd_tif  md75_grd_tif be75_grd_tif ds75_grd_tif mn75_grd_tif mi75_grd_tif  ;do 
cd $dir 
gdal_translate  -srcwin  5719 5249 1050 1050   6_1.tif  6_1_clip1.tif
gdal_translate  -srcwin  6200 6200 1050 550    6_1.tif  6_1_clip2.tif
gdal_translate  -srcwin  6700 6700 1050 550    6_1.tif  6_1_clip3.tif
gdal_translate  -srcwin  7150 7000 550  700    6_1.tif  6_1_clip4.tif
gdal_translate  -srcwin  6700 7550 1050 1100   6_1.tif  6_1_clip5.tif
gdal_translate  -srcwin  7150 8000 1050 1150   6_1.tif  6_1_clip6.tif

pksetmask -co COMPRESS=LZW -msknodata  0 -p '='  -nodata -27  -m 6_1_clip1.tif  -m 6_1_clip2.tif  -m 6_1_clip3.tif  -m 6_1_clip4.tif  -m 6_1_clip5.tif  -m 6_1_clip6.tif   -i 6_1.tif -o 6_1_correct.tif
mv  6_1.tif  6_1_orig.tiff
mv 6_1_correct.tif 6_1.tif
rm 6_1_clip*.tif

done 

# il 4_0.tif presenta pixel < 500 ma c'e' consistenci in the mn mi mx md quindi non vengon corretti 

# set all fhe file with -32768 no data value 

for dir in mx75_grd_tif  md75_grd_tif be75_grd_tif ds75_grd_tif mn75_grd_tif mi75_grd_tif  ;do 
    cd /lustre0/scratch/ga254/dem_bj/GMTED2010/tiles/$dir
    for file in *.tif ; do 
	gdal_edit.py -a_nodata -32768 $file 
    done 
done 
