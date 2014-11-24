# station arrive from 
# wget http://iacweb.ethz.ch/staff/gmueller/status_01.txt
# wget http://iacweb.ethz.ch/staff/gmueller/status_02.txt
# wget http://iacweb.ethz.ch/staff/gmueller/status_03.txt

cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/SOLAR/validation/geba/geo_file


awk  '{  if (NR>13) print $1 ,  $(NF-10) , $(NF-11) }' status_01_glo.txt > geba_code_x_y.txt
awk  '{  if (NR>13) print $1 ,  $(NF-10) , $(NF-11) }' status_02_dir.txt >> geba_code_x_y.txt
awk  '{  if (NR>13) print $1 ,  $(NF-10) , $(NF-11) }' status_03_dif.txt >> geba_code_x_y.txt
sort -k 1,1 geba_code_x_y.txt | uniq > geba_code_x_y_x360.txt

rm  geba_code_x_y.txt 
awk ' {  if ($2>180) {x=$2-360 }   else {x=$2} ; print $1 , x , $3 }'  geba_code_x_y_x360.txt > geba_code_x_y_x180.txt
 
