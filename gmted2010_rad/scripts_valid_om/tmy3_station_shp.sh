# works fine on bj
# change the format of csv data 

export INDIR=/lustre0/scratch/ga254/dem_bj/SOLAR/validation/nsrdb_tmy3/tmy3_csv
export OUTDIR=/lustre0/scratch/ga254/dem_bj/SOLAR/validation/nsrdb_tmy3/tmy3_txt

# sum the value at daily base and than average at montly base 

# '{  if (NR>2 ) print  substr($1,1,5)   , $5 , $8 , $11 }'
# Date  GHI (W/m^2) DNI (W/m^2) DHI (W/m^2) 

# Global horizontal irradiance   = Total amount of direct and diffuse solar radiation received on a horizontal surface during the 60-minute period ending at the timestamp 
# Direct normal  irradiance      = this is not usefull 
# Diffuse horizontal irradiance  = Amount of solar radiation received from the sky (excluding the solar disk) on a horizontal  surface during the 60-minute period ending at the timestamp


ls $INDIR/*.csv  | xargs   -n 1  -P 8 bash -c $'

file=$1
filename=`basename $file .csv`


awk -F ","  \'{  if (NR>2 ) print  substr($1,1,5)   , $5 , $8 , $11  }\' $file  > $OUTDIR/$filename.txt

/lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/WWF_ECO/sum.sh  $OUTDIR/$filename.txt $OUTDIR/${filename}_sum.txt <<EOF
n
1
0
EOF

awk   \'{  print  substr($1,1,2)   , $2 , $3 , $4  }\'    $OUTDIR/${filename}_sum.txt >   $OUTDIR/${filename}_sum_tmp.txt

/lustre0/scratch/ga254/scripts_bj/environmental-layers/terrain/procedures/dem_variables/gmted2010_rad/scripts_valid/average.sh   $OUTDIR/${filename}_sum_tmp.txt  $OUTDIR/${filename}_avg.txt   <<EOF
n
1
0
EOF


rm -f $OUTDIR/${filename}_sum_tmp.txt $OUTDIR/${filename}_sum.txt  $OUTDIR/$filename.txt
' _ 



# create shp with point  

ls /lustre0/scratch/ga254/dem_bj/SOLAR/validation/nsrdb_tmy3/tmy3_txt | awk '{  gsub("TY_avg.txt","") ;  print   }' | sort -k 1,1  > /lustre0/scratch/ga254/dem_bj/SOLAR/validation/nsrdb_tmy3/geo_file/TMY3_Stations.txt
join -1 1 -2 1 /lustre0/scratch/ga254/dem_bj/SOLAR/validation/nsrdb_tmy3/geo_file/TMY3_Stations.txt     <(awk -F ","  '{ if (NR>1) print $1 , $5 , $4  }' /lustre0/scratch/ga254/dem_bj/SOLAR/validation/nsrdb_tmy3/geo_file/TMY3_StationsMeta.csv  | sort -k 1,1)  >   /lustre0/scratch/ga254/dem_bj/SOLAR/validation/nsrdb_tmy3/geo_file/TMY3_Stations_x_y.txt


echo '"X","Y","CODE"' > /lustre0/scratch/ga254/dem_bj/SOLAR/validation/nsrdb_tmy3/shp_out/point_tmy3.csv
awk   '{ print $2","$3","$1 }'  /lustre0/scratch/ga254/dem_bj/SOLAR/validation/nsrdb_tmy3/geo_file/TMY3_Stations_x_y.txt  >> /lustre0/scratch/ga254/dem_bj/SOLAR/validation/nsrdb_tmy3/shp_out/point_tmy3.csv

echo "<OGRVRTDataSource>" > /lustre0/scratch/ga254/dem_bj/SOLAR/validation/nsrdb_tmy3/shp_out/point_tmy3.vrt
echo "    <OGRVRTLayer name=\"point_tmy3\">" >>  /lustre0/scratch/ga254/dem_bj/SOLAR/validation/nsrdb_tmy3/shp_out/point_tmy3.vrt
echo "        <SrcDataSource>/lustre0/scratch/ga254/dem_bj/SOLAR/validation/nsrdb_tmy3/shp_out/point_tmy3.csv</SrcDataSource>"  >> /lustre0/scratch/ga254/dem_bj/SOLAR/validation/nsrdb_tmy3/shp_out/point_tmy3.vrt
echo "	      <GeometryType>wkbPoint</GeometryType>"  >> /lustre0/scratch/ga254/dem_bj/SOLAR/validation/nsrdb_tmy3/shp_out/point_tmy3.vrt
echo "	      <GeometryField encoding=\"PointFromColumns\" x=\"X\" y=\"Y\" z=\"CODE\" /> "  >>  /lustre0/scratch/ga254/dem_bj/SOLAR/validation/nsrdb_tmy3/shp_out/point_tmy3.vrt
echo "    </OGRVRTLayer>"  >>  /lustre0/scratch/ga254/dem_bj/SOLAR/validation/nsrdb_tmy3/shp_out/point_tmy3.vrt
echo "</OGRVRTDataSource>"  >> /lustre0/scratch/ga254/dem_bj/SOLAR/validation/nsrdb_tmy3/shp_out/point_tmy3.vrt

rm -f    /lustre0/scratch/ga254/dem_bj/SOLAR/validation/nsrdb_tmy3/shp_out/point_tmy3.shp
ogr2ogr /lustre0/scratch/ga254/dem_bj/SOLAR/validation/nsrdb_tmy3/shp_out/point_tmy3.shp /lustre0/scratch/ga254/dem_bj/SOLAR/validation/nsrdb_tmy3/shp_out/point_tmy3.vrt




