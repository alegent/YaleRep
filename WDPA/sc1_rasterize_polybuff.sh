# rasterize poly and  buf 

#  ogr2ogr  -sql "SELECT WDPAID  FROM  WDPA_point_Oct2014_buff" WDPA_point_Oct2014_buffWDPAID.shp  WDPA_point_Oct2014_buff.shp
#  ogrinfo -al  -geom=no /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/shp_input/WDPA_point_Oct2014_buffWDPAID.shp  | grep "WDPAID " | awk ' { print $4}' > /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/tables/WDPAID_buffr.txt


#  ogr2ogr -sql "SELECT WDPAID  FROM  'WDPA-poly_Oct2014_1-60k'"  WDPA-poly_Oct2014_1-60kWDPAID.shp  WDPA-poly_Oct2014_1-60k.shp
#  ogrinfo -al  -geom=no /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/shp_input/WDPA-poly_Oct2014_1-60kWDPAID.shp  | grep "WDPAID " | awk ' { print $4}' > /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/tables/WDPAID_poly1.txt

#  ogr2ogr -sql "SELECT WDPAID  FROM  'WDPA-poly_Oct2014_60-120k'" WDPA-poly_Oct2014_60-120kWDPAID.shp  WDPA-poly_Oct2014_60-120k.shp
#  ogrinfo -al  -geom=no  /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/shp_input/WDPA-poly_Oct2014_60-120kWDPAID.shp      | grep "WDPAID " | awk ' { print $4}' > /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/tables/WDPAID_poly2.txt

#  ogr2ogr -sql "SELECT WDPAID  FROM  'WDPA-poly_Oct2014_60-120k'" WDPA-poly_Oct2014_120k-endWDPAID.shp  WDPA-poly_Oct2014_120k-end.shp
#  ogrinfo -al  -geom=no /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/shp_input/WDPA-poly_Oct2014_120k-endWDPAID.shp      | grep "WDPAID " | awk ' { print $4}' > /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/tables/WDPAID_poly3.txt


# 214694 observation 
# data preparation cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/tables

# for file in  WDPAID_buffr.txt WDPAID_poly1.txt WDPAID_poly2.txt WDPAID_poly3.txt ; do 
#     awk  ' {  print int(NR/10000), $1 } '   $file  > Blkid_$file
#     awk -v file=$file ' {  print  $2  >  "Blkid"$1"_"file    }'  Blkid_$file
# done 

# for file in  /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/tables/Blkid?_WDPAID_?????.txt  ; do qsub -v file=$file /home/fas/sbsc/ga254/scripts/WDPA/sc1_rasterize_polybuff.sh  ; done 

# bash  /home/fas/sbsc/ga254/scripts/WDPA/sc1_rasterize_polybuff.sh /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/tables/Blkid0_WDPAID_buffr.txt
# bash  /home/fas/sbsc/ga254/scripts/WDPA/sc1_rasterize_polybuff.sh /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/tables/Blkid0_WDPAID_poly3.txt

#PBS -S /bin/bash 
#PBS -q fas_normal
#PBS -l walltime=1:00:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /lustre/scratch/client/fas/sbsc/ga254/stdout 
#PBS -e /lustre/scratch/client/fas/sbsc/ga254/stderr

export INDIR=/dev/shm
export OUTDIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/tifs_out.tar

checkjob -v $PBS_JOBID  > /scratch/fas/sbsc/ga254/stdnode/job_start_$PBS_JOBID.txt


# file=$1 

blk=$(basename $file .txt ) 
shpend=${blk: -12}

echo  $shpend

if [  $shpend = WDPAID_buffr ] ; then shp=WDPA_point_Oct2014_buffWDPAID ; fi 
if [  $shpend = WDPAID_poly1 ] ; then shp=WDPA-poly_Oct2014_1-60kWDPAID ; fi 
if [  $shpend = WDPAID_poly2 ] ; then shp=WDPA-poly_Oct2014_60-120kWDPAID ; fi 
if [  $shpend = WDPAID_poly3 ] ; then shp=WDPA-poly_Oct2014_120k-endWDPAID ; fi 


export shp=$shp 

cp /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/shp_input/$shp.*   $INDIR/

# il gdal_rasterize con sql non funziona 
# see  http://spatial-ecology.net/dokuwiki/doku.php?id=wiki:cluster_xargs
# store at /mnt/data2/scratch/WDPA_new/txt_out/list_id_not_done.txt 

cat $file      | xargs -n 1  -P 8  bash -c  $'

id=$1

echo select a single poly   and create $INDIR/wdpa2014_id${id}.shp

rm  -f  $INDIR/wdpa2014_id${id}.* 
ogr2ogr -sql "SELECT * FROM  \'$shp\'    WHERE   ( WDPAID  = ${id} )   "  $INDIR/wdpa2014_id${id}.shp   $INDIR/$shp.shp

rm -f  $INDIR/wdpa2014_id${id}.tif
gdal_rasterize -at   -ot  UInt32   -a_srs EPSG:4326 -l wdpa2014_id${id}  -a WDPAID  -a_nodata 0 -tap -tr  0.008333333333333 0.008333333333333  -co COMPRESS=LZW -co ZLEVEL=9    $INDIR/wdpa2014_id${id}.shp   $INDIR/wdpa2014_id${id}.tif 

rm -f  $INDIR/wdpa2014_id${id}.{shx,dbf,prj,shp}

' _

echo start the tar of $blk

cd  $INDIR/

tar  -cf $INDIR/${blk}_tifs.tar    $( for id in $(  cat $file)  ; do  if [ -f  $INDIR/"wdpa2014_id"$id".tif"  ] ; then    echo  "wdpa2014_id"$id".tif"  ; fi ; done )  
mv  $INDIR/${blk}_tifs.tar /lustre/scratch/client/fas/sbsc/ga254/dataproces/WDPA/tifs_out.tar/
rm -r  $INDIR/wdpa2014_id*.tif   $INDIR/WDPA-poly_Oct2014*WDPAID.*

checkjob -v $PBS_JOBID  > /scratch/fas/sbsc/ga254/stdnode/job_end_$PBS_JOBID.txt

