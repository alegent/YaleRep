#  cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/tile_txt
#  awk 'NR%8==1 {x="F"++i;}{ print >   "tiles8_list"x".txt" }'  tiles_list.txt  ; 
#  awk 'NR%16==1 {x="F"++i;}{ print >  "tiles16_list"x".txt" }'  tiles_list.txt  ; 

# cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/tile_txt
# for list  in  tiles8_listF?.txt  tiles8_listF??.txt  ; do qsub -v list=$list /lustre/home/client/fas/sbsc/ga254/scripts/GFC2013/sc2_first_nvdi_homogenity.sh   ; done 

# bash  /lustre/home/client/fas/sbsc/ga254/scripts/GFC2013/sc2_first_nvdi_homogenity.sh  tiles8_listF52.txt

#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=24:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

export INDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/first_ndvi
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/first_ndvi_HOM/tiles
export RAM=/dev/shm
rm -rf $RAM/*

export list=$list

cat /lustre/scratch/client/fas/sbsc/ga254/dataproces/GFC2013/tile_txt/$list  | xargs -n 1 -P 8  bash -c $' 
tile=$1 

echo process $tile

pkinfo -te   -i  $INDIR/Hansen_GFC2014_first_${tile}_ndvi_msk.tif > $RAM/te_$tile.txt 

xmin=$(awk \'{ print $2 -0.02  }\'   $RAM/te_$tile.txt )  
ymin=$(awk \'{ print $3 -0.02  }\'   $RAM/te_$tile.txt )  
xmax=$(awk \'{ print $4 +0.02  }\'   $RAM/te_$tile.txt )  
ymax=$(awk \'{ print $5 +0.02  }\'   $RAM/te_$tile.txt )  


gdalbuildvrt     -te $xmin $ymin $xmax $ymax  -o $RAM/Hansen_GFC2014_first_${tile}_ndvi_msk.vrt      $INDIR/Hansen_GFC2014_first_*_ndvi_msk.tif
gdal_translate   -co COMPRESS=LZW -co ZLEVEL=9  $RAM/Hansen_GFC2014_first_${tile}_ndvi_msk.vrt       $RAM/Hansen_GFC2014_first_${tile}_ndvi_msk.tif 

python /lustre/home/client/fas/sbsc/ga254/scripts/GFC2013/Aggregation_GLCM.py   -m "HOM" -mm 100 0 -no 255 -l 101 -o $RAM  -ref /lustre/scratch/client/fas/sbsc/ga254/dataproces/GEO_AREA/tif_ID/glob_ID0_rast.tif  -qa $RAM/Hansen_GFC2014_first_${tile}_ndvi_msk.tif 

' _ 

mv  $RAM/HOM_*.tif  $OUTDIR

rm -rf $RAM/*