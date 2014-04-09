
# cd /mnt/data2/scratch/GMTED2010/solar_radiation/nrel/csv
# ls /mnt/data2/scratch/GMTED2010/solar_radiation/nrel/csv/*TY.csv  | xargs -n 1 -P 10 bash /mnt/data2/scratch/GMTED2010/solar_radiation/scripts/sc2_rad_extraction.sh

INDIR=/mnt/data2/scratch/GMTED2010/solar_radiation/nrel/csv
file=$1
filename=$(basename $file .csv)

LAT=$(grep ${filename:0:6} $INDIR/TMY3_StationsMeta.csv | awk -F "," '{  print $4  }')
LON=$(grep ${filename:0:6} $INDIR/TMY3_StationsMeta.csv | awk -F "," '{  print $5  }')

# echo $LON $LAT
# check if the point fall inside the tile 


intile=$(gdallocationinfo -geoloc -wgs84 /mnt/data2/scratch/GMTED2010/grassdb/glob_rad/1/glob_rad_day1_2_1.tif $LON $LAT |tail -1   | awk '{ print $1}')

# echo $intile

if [ $intile = "Location" ] ; then 
    exit
else
    echo extract data from  rad_grass_data using file $file
    rm -f /mnt/data2/scratch/GMTED2010/solar_radiation/nrel/txt_grass_rad/${filename:0:6}_rad.txt
    for day in `seq 1 80` ; do 
        echo $day  $(gdallocationinfo -valonly  -geoloc -wgs84 /mnt/data2/scratch/GMTED2010/grassdb/glob_rad/$day/glob_rad_day${day}_2_1.tif $LON $LAT) >> /mnt/data2/scratch/GMTED2010/solar_radiation/nrel/txt_grass_rad/${filename:0:6}_rad.txt
#	gdallocationinfo -valonly  -geoloc -wgs84 /mnt/data2/scratch/GMTED2010/grassdb/diff_rad/$day/diff_rad_day${day}_2_1.tif $LON $LAT
#	gdallocationinfo -valonly  -geoloc -wgs84 /mnt/data2/scratch/GMTED2010/grassdb/beam_rad/$day/beam_rad_day${day}_2_1.tif $LON $LAT
#	gdallocationinfo -valonly  -geoloc -wgs84 /mnt/data2/scratch/GMTED2010/grassdb/refl_rad/$day/refl_rad_day${day}_2_1.tif $LON $LAT
    done  
fi 

# paste <(awk '{ if ( NR>1 &&  NR<82 ) print $5  }' /mnt/data2/scratch/GMTED2010/solar_radiation/nrel/csv/690190TY_sumH.txt)  <( awk '{  print $2  }'  /mnt/data2/scratch/GMTED2010/solar_radiation/nrel/txt_grass_rad/690190_rad.txt )> test.txt