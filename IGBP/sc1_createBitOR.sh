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
echo 11 100000000000        >> reclass.txt 
echo 12 1000000000000        >> reclass.txt 
echo 13 10000000000000        >> reclass.txt 
echo 14 100000000000000        >> reclass.txt 
echo 15 1000000000000000        >> reclass.txt 
echo 16 10000000000000000        >> reclass.txt 

awk '{ print $2 }' reclass.txt >   reclass_bin.txt

(echo ibase=2; sed 's/ //g'  reclass_bin.txt   ) | bc >  reclass_bit.txt



seq 0 16  | xargs -n 1 -P 17 bash -c $' 

n=$1

pkreclass  -ot UInt16  -o IGBP_class${n}_binary_30secBit.tif -i   IGBP_class${n}_binary_30sec.tif  --class 0  --reclass 0  --class 1  --reclass  $( awk -v n=$n \'{ if (NR==(n+1)) print $1  }\'  reclass_bit.txt  )   -co COMPRESS=LZW -co ZLEVEL=9

' _ 



convert -depth 16   IGBP_class0_binary_30secBit.tif   IGBP_class1_binary_30secBit.tif -fx "(((65536*u)&(65536*(1-v)))|((65536*(1-u))&(65536*v)))/65536"   IGBP_class_binary_30secBitALL.tif
  
for n in $(seq 2 16)  ; do  
convert IGBP_class${n}_binary_30secBit.tif  IGBP_class_binary_30secBitALL.tif  -fx "u | v" IGBP_class_binary_30secBitALL.tif
done 

