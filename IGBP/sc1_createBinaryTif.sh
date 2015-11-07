cd /media/data/tmp/Combined_MODIS 

echo 0  1          > reclass.txt 
echo 1  10        >> reclass.txt 
echo 2  100        >> reclass.txt 
echo 3  1000        >> reclass.txt 
echo 4  10000        >> reclass.txt 
echo 5  100000        >> reclass.txt 
echo 6  1000000        >> reclass.txt 
echo 7  10000000        >> reclass.txt 
echo 8  100000000        >> reclass.txt 
echo 9  1000000000        >> reclass.txt 
echo 10 10000000000        >> reclass.txt 
echo 11 10000000000        >> reclass.txt 
echo 12 10000000000        >> reclass.txt 
echo 13 10000000000        >> reclass.txt 
echo 14 10000000000        >> reclass.txt 
echo 15 10000000000        >> reclass.txt 
echo 16 10000000000        >> reclass.txt 

# # up to the 11 because the $number is truncated as avariable. 

cat   reclass.txt  | xargs -n 2 -P 17 bash -c $' 

number=$1
mult=$2

if [ ! -f   IGBP_class${number}_binary_30secFc.tif  ] ; then  

oft-calc -ot Float64  IGBP_class${number}_binary_30sec.tif IGBP_class${number}_binary_30secF.tif <<EOF
1
#1 $mult *
EOF

fi

' _ 


for n in $(seq 0 16) ; do     gdal_translate   -co COMPRESS=LZW -co ZLEVEL=9     IGBP_class${n}_binary_30secF.tif  IGBP_class${n}_binary_30secFc.tif ; rm -f  IGBP_class${n}_binary_30secF.tif ; done 

rm *.eq

echo 11 10        > reclass2.txt 
echo 12 100        >> reclass2.txt 
echo 13 1000        >> reclass2.txt 
echo 14 10000        >> reclass2.txt 
echo 15 100000        >> reclass2.txt 
echo 16 1000000        >> reclass2.txt 


echo start the second oft-calc

cat   reclass2.txt  | xargs -n 2 -P 17 bash -c $' 


number=$1
mult=$2

oft-calc -ot Float64  IGBP_class${number}_binary_30secFc.tif IGBP_class${number}_binary_30secFF.tif <<EOF
1
#1 $mult *
EOF

' _ 


for n in $(seq 11 16) ; do  gdal_translate   -co COMPRESS=LZW -co ZLEVEL=9     IGBP_class${n}_binary_30secFF.tif  IGBP_class${n}_binary_30secFFc.tif ; rm -f  IGBP_class${n}_binary_30secFF.tif 

rm *.eq

pkcomposite $(for n in $(seq 0 10 ) ; do echo  -i  IGBP_class${n}_binary_30secFc.tif ; done )   $(for n in $(seq 11 16 ) ; do echo  -i  IGBP_class${n}_binary_30secFFc.tif ; done )  -ot Float64    -co COMPRESS=LZW -co ZLEVEL=9   -o  IGBP_classAll_binary_30secFc.tif -cr sum

