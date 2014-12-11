# bash    /lustre0/scratch/ga254/dem_bj/Range_map/sister/script/sc3_join_table.sh

cd /lustre0/scratch/ga254/dem_bj/Range_map/sister/txt_couple

echo create overlap_area.txt

# sortint the file if re-run 

rm *_s.txt

ls *.txt | xargs -n 1 -P 20 bash -c   $'  
     
file=$1
echo processing $file 
filename=$(basename $file .txt ) 
sort  -k 1,1 -g <(awk \'{ if ($1!=255) print }\'   $file ) > $filename"_s.txt"   # there are some files that have 255 on the border pixel

' _ 

for file in *_s.txt  ; do filename=$(basename $file _s.txt ) ;  echo $( echo $filename | awk '{ gsub ("_" , " ") ;  print $1"_"$2 , $3"_"$4 }' )   $(  awk  '{ col=$1 ; area=$3 } END { if (col==2 ) { print int(area) } else {  print "0"} }'  $file ) ; done   >  /lustre0/scratch/ga254/dem_bj/Range_map/sister/txt_final/overlap_area.txt


echo sorting 

sort -k 1,1 /lustre0/scratch/ga254/dem_bj/Range_map/sister/txt_final/overlap_area.txt >  /lustre0/scratch/ga254/dem_bj/Range_map/sister/txt_final/overlap_area_s.txt

cd /lustre0/scratch/ga254/dem_bj/Range_map/sister/txt

for file in *.txt ; do filename=$(basename $file .txt ) ;   echo $filename    $(awk  '{ print int($3)  }'  $file ) ; done  > /lustre0/scratch/ga254/dem_bj/Range_map/sister/txt_final/species_area.txt 

sort -k 1,1 /lustre0/scratch/ga254/dem_bj/Range_map/sister/txt_final/species_area.txt  >  /lustre0/scratch/ga254/dem_bj/Range_map/sister/txt_final/species_area_s.txt 

join -1 1 -2 1  /lustre0/scratch/ga254/dem_bj/Range_map/sister/txt_final/overlap_area_s.txt  /lustre0/scratch/ga254/dem_bj/Range_map/sister/txt_final/species_area_s.txt >   /lustre0/scratch/ga254/dem_bj/Range_map/sister/txt_final/overalp_species_area1.txt 


sort -k 2,2 /lustre0/scratch/ga254/dem_bj/Range_map/sister/txt_final/overalp_species_area1.txt >  /lustre0/scratch/ga254/dem_bj/Range_map/sister/txt_final/overalp_species_area1_s.txt  

echo "Sister1 Sister2  areaOverlap areaSister1 areaSister2" >  /lustre0/scratch/ga254/dem_bj/Range_map/sister/txt_final/overalp_species_area1_area2.txt 
join -1 2 -2 1  /lustre0/scratch/ga254/dem_bj/Range_map/sister/txt_final/overalp_species_area1_s.txt    /lustre0/scratch/ga254/dem_bj/Range_map/sister/txt_final/species_area_s.txt >> /lustre0/scratch/ga254/dem_bj/Range_map/sister/txt_final/overalp_species_area1_area2.txt 

awk '{  print $1","$2","$3","$4","$5 }'   /lustre0/scratch/ga254/dem_bj/Range_map/sister/txt_final/overalp_species_area1_area2.txt  >   /lustre0/scratch/ga254/dem_bj/Range_map/sister/txt_final/overalp_species_area1_area2.csv 

 
# in the orig csv  Eurochelidon_sirintarae  instead  Eurochelidon_sirinta.shp  create Eurochelidon_sirintarae.shp
# in the orig csv  Xiphorhynchus_elegans    instead  Xiphorhynchus_elegan.shp  create Xiphorhynchus_elegans.shp

