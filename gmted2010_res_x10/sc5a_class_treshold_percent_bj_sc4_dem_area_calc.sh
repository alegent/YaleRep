# This is not a stand alone script, adjust it in accordance to the location of the files. 
# It run in 2 hours on my local machine. No parallel processing has been implemented.
# It possible to change to multicore, one poligon for each processor. 

# Task 
# Calculate area over a certan elavation using the threshold_????_GMTED2010_md.tif as input ( all the pixel > 0 are considered for the calculation).

# the calculation is done in each poiligon of the shape file 
# the area is calculate by summing the value of the pixel of GMTED2010_30arc-sec-AreaCol_merge.tif. In this tif the pixel value is the area in m2 of that pixel 

# rasterize the shapefile 

# procedure 
# get bounding box of the poligon
# clip the GMTED2010_30arc-sec-AreaCol_merge.tif
# clip Global_GMBA_clip.tif  and use as maks
# clip threshold_????_GMTED2010_md.tif and use as a mask
# sum the pixel inside the poligon derived by the 2 masks

for id in 513 ; do 

    echo "***********************" processint id $id  

    gdal_translate -srcwin  24764 5756 2025 1073  30arc-sec-Area_prjR.tif  30arc-sec-Area_prjR_clip.tif 
    gdal_translate -srcwin  24764 5756 2025 1073 Global_GMBA.tif Global_GMBA_clip.tif 

    rm -r  table/ID$id"_threshold_areakm2.txt"   
    
    for alt in  `seq 0 100 4100` ; do 
	echo  "*************************************" clipping the threshold $alt dem
        gdal_translate -projwin $(getCorners4Gtranslate Global_GMBA_clip.tif) -a_ullr $(getCorners4Gtranslate Global_GMBA_clip.tif)  class/dem513_C$alt"Perc.tif" class/threshold_$alt"_GMTED2010_md_clip.tif"
	pksetmask -ot UInt32 -co COMPRESS=LZW  -i class/threshold_$alt"_GMTED2010_md_clip.tif"    -m Global_GMBA_clip.tif -t $id -f 0 --operator '!' -o class/threshold_$alt"_GMTED2010_md_mask.tif"
	gdal_calc.py    -A    30arc-sec-Area_prjR_clip.tif   -B class/threshold_$alt"_GMTED2010_md_mask.tif"  --calc="( A * B)"  --outfile class/area_clipBYmi_$alt"Tth_md_mask.tif"    --overwrite 
 	# this line calculate the area by summing the value of the histogram                           convert from m2 to km2                               create the table
      echo $id $alt $(pkinfo --hist   -i  class/area_clipBYmi_$alt"Tth_md_mask.tif" | awk '{ sum = sum + ($1*$2/100000000)  } END {printf ("%20i\n",  sum ) }')   >> table/ID$id"_threshold_areakm2.txt"   

    done 
done





