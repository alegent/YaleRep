

# cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA2015/tables

# rm Blkid_WDPAID.txt

# total 217839 WDPAID.txt 

# for file in /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA2015/tables/Blkid*_WDPAID.txt   ; do qsub -v file=$file /home/fas/sbsc/ga254/scripts/WDPA2015/sc1_rasterize_polybuff.sh  ; done 

# bash  /home/fas/sbsc/ga254/scripts/WDPA2015/sc1_rasterize_polybuff.sh /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA2015/tables/Blkid0_WDPAID.txt 

#PBS -S /bin/bash 
#PBS -q fas_high
#PBS -l walltime=1:00:00:00 
#PBS -l nodes=1:ppn=8
#PBS -l mem=34gb
#PBS -V
#PBS -o /lustre/scratch/client/fas/sbsc/ga254/stdout 
#PBS -e /lustre/scratch/client/fas/sbsc/ga254/stderr

export RAM=/dev/shm
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA2015/tifs_out.tar

checkjob -v $PBS_JOBID  > /scratch/fas/sbsc/ga254/stdnode/job_start_$PBS_JOBID.txt

# file=$1 

blk=$(basename $file .txt ) 
shpend=${blk: -12}

cp /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA2015/shp_input/poly.*   $RAM/

# il gdal_rasterize con sql non funziona 
# see  http://spatial-ecology.net/dokuwiki/doku.php?id=wiki:cluster_xargs
# store at /mnt/data2/scratch/WDPA2015_new/txt_out/list_id_not_done.txt 

cat   $file      | xargs -n 1  -P 8  bash -c  $'

id=$1

echo select a single poly   and create $RAM/wdpa_id${id}.shp

rm  -f  $RAM/wdpa_id${id}.* 
ogr2ogr -sql "SELECT * FROM  poly    WHERE   ( WDPAID  = ${id} )"   $RAM/wdpa_id${id}.shp   $RAM/poly.shp

rm -f  $RAM/wdpa_id${id}.tif
gdal_rasterize -at   -ot  UInt32   -a_srs EPSG:4326 -l wdpa_id${id}  -a WDPAID  -a_nodata 0 -tap -tr  0.008333333333333 0.008333333333333  -co COMPRESS=LZW -co ZLEVEL=9    $RAM/wdpa_id${id}.shp   $RAM/wdpa_id${id}.tif 

rm -f  $RAM/wdpa_id${id}.{shx,dbf,prj,shp}

' _

exit 

echo start the tar of $blk

cd  $RAM/

tar  -cf $RAM/${blk}_tifs.tar    $( for id in $(  cat $file)  ; do  if [ -f  $RAM/"wdpa_id"$id".tif"  ] ; then    echo  "wdpa_id"$id".tif"  ; fi ; done )  
mv  $RAM/${blk}_tifs.tar /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA2015/tifs_out.tar/
rm -r  $RAM/wdpa_id*.tif   $RAM/WDPA-poly_Oct*WDPAID.*

checkjob -v $PBS_JOBID  > /scratch/fas/sbsc/ga254/stdnode/job_end_$PBS_JOBID.txt

