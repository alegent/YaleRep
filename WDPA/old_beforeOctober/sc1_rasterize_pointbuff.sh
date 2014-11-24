# rasterize the buf 
# qsub     /home/fas/sbsc/ga254/scripts/WDPA/sc1_rasterize_pointbuff.sh

# ogrinfo -al -geom=no   /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/shp_input/WDPA_protect_april2014_clean/WDPA_protect_april2014_EPSG4326Buf2.shp     | grep "WDPAID "  | awk '{ print $4}'   > /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/tif_out_buf/list_id.txt 


#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=1:00:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /lustre/scratch/client/fas/sbsc/ga254/stdout 
#PBS -e /lustre/scratch/client/fas/sbsc/ga254/stderr

export INDIR=/dev/shm
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/tif_out_buf

checkjob -v $PBS_JOBID  > /scratch/fas/sbsc/ga254/stdnode/job_start_$PBS_JOBID.txt

cp /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/shp_input/WDPA_protect_april2014_clean/WDPA_protect_april2014_EPSG4326Buf2.*   $INDIR/

# il gdal_rasterize con sql non funziona 

# see  http://spatial-ecology.net/dokuwiki/doku.php?id=wiki:cluster_xargs
# store at /mnt/data2/scratch/WDPA_new/txt_out/list_id_not_done.txt 


cat /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/tif_out_buf/list_id.txt    | xargs -n 1  -P 8  bash -c  $'

id=$1

echo select a single poly   $OUTDIR/wdpa2014_id${id}.shp

rm  -f  $INDIR/wdpa2014_id${id}.* 
ogr2ogr -sql "SELECT * FROM WDPA_protect_april2014_EPSG4326Buf2   WHERE   ( WDPAID  = ${id} )"  $INDIR/wdpa2014_id${id}.shp   $INDIR/WDPA_protect_april2014_EPSG4326Buf2.shp 

rm -f  $INDIR/wdpa2014_id${id}.tif
gdal_rasterize -at   -ot  UInt32   -a_srs EPSG:4326 -l wdpa2014_id${id}  -a WDPAID  -a_nodata 0 -tap -tr  0.008333333333333 0.008333333333333  -co COMPRESS=LZW -co ZLEVEL=9    $INDIR/wdpa2014_id${id}.shp   $INDIR/wdpa2014_id${id}.tif 

rm -f  $INDIR/wdpa2014_id${id}.{shx,dbf,prj,shp}


' _

scp  $INDIR/wdpa2014_id*.tif  /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/tif_out_buf

rm -r  $INDIR/wdpa2014_id*.tif   $INDIR/WDPA_protect_april2014_EPSG4326Buf2.*

checkjob -v $PBS_JOBID  > /scratch/fas/sbsc/ga254/stdnode/job_end_$PBS_JOBID.txt