cd /media/data/tmp/Combined_MODIS 

echo 0  0         > reclass0.txt 
echo 1  1        >> reclass0.txt 

echo 0  0         > reclass1.txt 
echo 1  10        >> reclass1.txt 

echo 0  0         > reclass2.txt 
echo 1  100        >> reclass2.txt 

echo 0  0         > reclass3.txt 
echo 1  1000        >> reclass3.txt 

echo 0  0         > reclass4.txt 
echo 1  10000        >> reclass4.txt 

echo 0  0         > reclass5.txt 
echo 1  100000        >> reclass5.txt 

echo 0  0         > reclass6.txt 
echo 1  1000000        >> reclass6.txt 

echo 0  0         > reclass7.txt 
echo 1  10000000        >> reclass7.txt 

echo 0  0         > reclass8.txt 
echo 1  100000000        >> reclass8.txt 

echo 0  0         > reclass9.txt 
echo 1  1000000000        >> reclass9.txt 

echo 0  0         > reclass10.txt 
echo 1  10000000000        >> reclass10.txt 

echo 0  0         > reclass11.txt 
echo 1  100000000000        >> reclass11.txt 

echo 0  0         > reclass12.txt 
echo 1  1000000000000        >> reclass12.txt 

echo 0  0         > reclass13.txt 
echo 1  10000000000000        >> reclass13.txt 

echo 0  0         > reclass14.txt 
echo 1  100000000000000        >> reclass14.txt 

echo 0  0         > reclass15.txt 
echo 1  1000000000000000        >> reclass15.txt 

echo 0  0         > reclass16.txt 
echo 1  10000000000000000        >> reclass16.txt 

# # up to the 11 because the $number is truncated as avariable. 

seq 0 16  | xargs -n 1 -P 17 bash -c $' 

n=$1

pkreclass  -ot Float32  -o IGBP_class${n}_binary_30secF.tif -i   IGBP_class${n}_binary_30sec.tif  -code  reclass${n}.txt  -co COMPRESS=LZW -co ZLEVEL=9

' _ 


pkcomposite $(for n in $(seq 0 16 ) ; do echo  -i  IGBP_class${n}_binary_30secF.tif ; done )  -ot  Float32    -co COMPRESS=LZW -co ZLEVEL=9   -o  IGBP_classAll_binary_30secF.tif -cr sum

