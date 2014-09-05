
# crop them to have the right extention 
# for file in *.tif ; do filename=$(basename $file .tif ) ; gdal_translate  -projwin -180 +90 +180 -90     -co  COMPRESS=LZW -co ZLEVEL=9 $file /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/rasterize/tif_class/${filename}_crop.tif ; done

# for file in  /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/rasterize/tif_class/wdpaid_IUCN_??_?_crop.tif  ; do qsub -v file=$file /home/fas/sbsc/ga254/scripts/WDPA/sc3_reclassbygrass_IUCN_class_tif.sh ; done 
# for file in /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/rasterize/tif_class/.... ; do bash /home/fas/sbsc/ga254/scripts/WDPA/sc3_reclassbygrass_IUCN_class_tif.sh  $file ; done  


#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=00:01:00:00  
#PBS -l nodes=1:ppn=1
#PBS -V
#PBS -o  /scratch/fas/sbsc/ga254/stdout 
#PBS -e  /scratch/fas/sbsc/ga254/stderr

checkjob -v $PBS_JOBID  > /scratch/fas/sbsc/ga254/stdnode/job_start_$PBS_JOBID.txt

file=$file 

INDIRTIF=/lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/rasterize/tif_class
OUTDIRTIF=/lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/rasterize/tif_class_reclass
DIRTXT=/lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/txt
RAMDIRG=/dev/shm/

filename=$(basename $file .tif )


echo create location  loc_$filename 

rm -rf  /dev/shm/*
mkdir -p  $RAMDIRG/loc_tmp/tmp

echo "LOCATION_NAME: loc_tmp"                                                       > $HOME/.grass7/rc_$filename
echo "GISDBASE: /dev/shm"                                                          >> $HOME/.grass7/rc_$filename
echo "MAPSET: tmp"                                                                 >> $HOME/.grass7/rc_$filename
echo "GRASS_GUI: text"                                                             >> $HOME/.grass7/rc_$filename

# path to GRASS settings file
export GISRC=$HOME/.grass7/rc_$filename
export GRASS_PYTHON=python
export GRASS_MESSAGE_FORMAT=plain
export GRASS_PAGER=cat
export GRASS_WISH=wish
export GRASS_ADDON_BASE=$HOME/.grass7/addons
export GRASS_VERSION=7.0.0beta1
export GISBASE=/usr/local/cluster/hpc/Apps/GRASS/7.0.0beta1/grass-7.0.0beta1
export GRASS_PROJSHARE=/usr/local/cluster/hpc/Libs/PROJ/4.8.0/share/proj/
export PROJ_DIR=/usr/local/cluster/hpc/Libs/PROJ/4.8.0

export PATH="$GISBASE/bin:$GISBASE/scripts:$PATH"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"$GISBASE/lib"
export GRASS_LD_LIBRARY_PATH="$LD_LIBRARY_PATH"
export PYTHONPATH="$GISBASE/etc/python:$PYTHONPATH"
export MANPATH=$MANPATH:$GISBASE/man
export GIS_LOCK=$$
export GRASS_OVERWRITE=1

rm -rf  $RAMDIRG/loc_$filename

echo start importing 
r.in.gdal in=$INDIRTIF/$filename.tif   out=$filename  location=loc_$filename

g.mapset mapset=PERMANENT  location=loc_$filename

r.report $filename  -h | awk 'BEGIN {print 0,0 } { if (NR>4) { gsub("\\|","") ; if ($1>1)  { print $1 , NR-4 } } }'   > $DIRTXT/${filename}_reclass.txt 

awk '{  print $1":"$1":"$2":"$2  }' $DIRTXT/${filename}_reclass.txt  > $DIRTXT/${filename}_reclass_4grass.txt


r.recode  input=$filename  output=${filename}_rec   rules=$DIRTXT/${filename}_reclass_4grass.txt 


r.out.gdal -c type=UInt32  nodata=0  createopt="COMPRESS=LZW,ZLEVEL=9" input=${filename}_rec  output=$OUTDIRTIF/${filename}_rec.tif --overwrite

rm -rf  /dev/shm/*

checkjob -v $PBS_JOBID  > /scratch/fas/sbsc/ga254/stdnode/job_end_$PBS_JOBID.txt