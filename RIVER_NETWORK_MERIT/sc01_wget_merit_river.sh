#!/bin/bash
#SBATCH -p day
#SBATCH -n 1 -c 12  -N 1  
#SBATCH -t 24:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email
#SBATCH -e  /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc01_wget_merit_river.sh%J.err
#SBATCH -o  /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc01_wget_merit_river.sh%J.out

# sbatch   /gpfs/home/fas/sbsc/ga254/scripts/RIVER_NETWORK_MERIT/sc01_wget_merit_river.sh

# download 

# Flow Direction Map

export MERIT=/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/RIVER_NETWORK_MERIT
cd /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/RIVER_NETWORK_MERIT/dir

# Flow direction is prepared in 1-byte SIGNED integer (int8). The flow direction is represented as follows.
# 1: east, 2: southeast, 4: south, 8: southwest, 16: west, 32: northwest, 64: north. 128: northeast
# 0: river mouth, -1: inland depression, -9: undefined (ocean)
# NOTE: If a flow direction file is opened as UNSIGNED integer, undefined=247 and inland depression=255

for file in dir_n60w180.tar.gz dir_n60e000.tar.gz dir_n60w150.tar.gz dir_n60e030.tar.gz dir_n60w120.tar.gz dir_n60e060.tar.gz dir_n60w090.tar.gz dir_n60e090.tar.gz dir_n60w060.tar.gz dir_n60e120.tar.gz dir_n60w030.tar.gz dir_n60e150.tar.gz dir_n30w180.tar.gz dir_n30e000.tar.gz dir_n30w150.tar.gz dir_n30e030.tar.gz dir_n30w120.tar.gz dir_n30e060.tar.gz dir_n30w090.tar.gz dir_n30e090.tar.gz dir_n30w060.tar.gz dir_n30e120.tar.gz dir_n30w030.tar.gz dir_n30e150.tar.gz dir_n00w180.tar.gz dir_n00e000.tar.gz n00w150 dir_n00e030.tar.gz dir_n00w120.tar.gz dir_n00e060.tar.gz dir_n00w090.tar.gz dir_n00e090.tar.gz dir_n00w060.tar.gz dir_n00e120.tar.gz dir_n00w030.tar.gz dir_n00e150.tar.gz dir_s30w180.tar.gz dir_s30e000.tar.gz dir_s30w150.tar.gz dir_s30e030.tar.gz dir_s30w120.tar.gz dir_s30e060.tar.gz dir_s30w090.tar.gz dir_s30e090.tar.gz dir_s30w060.tar.gz dir_s30e120.tar.gz dir_s30w030.tar.gz dir_s30e150.tar.gz dir_s60w180.tar.gz dir_s60e000.tar.gz dir_s60e030.tar.gz dir_s60e060.tar.gz dir_s60w090.tar.gz dir_s60e090.tar.gz dir_s60w060.tar.gz dir_s60e120.tar.gz dir_s60w030.tar.gz dir_s60e150.tar.gz ; do 
wget --user=flowdirection  --password=testdirection   http://hydro.iis.u-tokyo.ac.jp/~yamadai/GlobalDir/distribute/v0.2/$file 
tar zxf $file  ; rm  -f  $file 

export file 
export filename=$(basename $file  .tar.gz  )

ls /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/RIVER_NETWORK_MERIT/dir/$filename/*_dir.tif | xargs -n 1 -P 12  bash -c $' 
tifname=$(basename $1 )
gdal_translate  -a_nodata 247 -co COMPRESS=DEFLATE  -co ZLEVEL=9   -a_ullr $(getCorners4Gtranslate $1 | awk \'{  printf ("%.0f %.0f %.0f %.0f " ,  $1 , $2 , $3 , $4 )  }\' )  $1 $MERIT/dir/$tifname 
' _ 

rm -f $MERIT/dir/$filename
done

gdalbuildvrt -overwrite   -srcnodata 274 -vrtnodata 247    $MERIT/dir/all_tif.vrt $MERIT/dir/*_dir.tif 
rm -fr  /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/RIVER_NETWORK_MERIT/dir/dir_*
rm -fr  /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/RIVER_NETWORK_MERIT/dir/*.tar.gz


# Hydrologically Adjusted Elevations 
cd /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/RIVER_NETWORK_MERIT/elv

for file in elv_n60w180.tar.gz elv_n60e000.tar.gz elv_n60w150.tar.gz elv_n60e030.tar.gz elv_n60w120.tar.gz elv_n60e060.tar.gz elv_n60w090.tar.gz elv_n60e090.tar.gz elv_n60w060.tar.gz elv_n60e120.tar.gz elv_n60w030.tar.gz elv_n60e150.tar.gz elv_n30w180.tar.gz elv_n30e000.tar.gz elv_n30w150.tar.gz elv_n30e030.tar.gz elv_n30w120.tar.gz elv_n30e060.tar.gz elv_n30w090.tar.gz elv_n30e090.tar.gz elv_n30w060.tar.gz elv_n30e120.tar.gz elv_n30w030.tar.gz elv_n30e150.tar.gz elv_n00w180.tar.gz elv_n00e000.tar.gz n00w150 elv_n00e030.tar.gz elv_n00w120.tar.gz elv_n00e060.tar.gz elv_n00w090.tar.gz elv_n00e090.tar.gz elv_n00w060.tar.gz elv_n00e120.tar.gz elv_n00w030.tar.gz elv_n00e150.tar.gz elv_s30w180.tar.gz elv_s30e000.tar.gz elv_s30w150.tar.gz elv_s30e030.tar.gz elv_s30w120.tar.gz elv_s30e060.tar.gz elv_s30w090.tar.gz elv_s30e090.tar.gz elv_s30w060.tar.gz elv_s30e120.tar.gz elv_s30w030.tar.gz elv_s30e150.tar.gz elv_s60w180.tar.gz elv_s60e000.tar.gz elv_s60e030.tar.gz elv_s60e060.tar.gz elv_s60w090.tar.gz elv_s60e090.tar.gz elv_s60w060.tar.gz elv_s60e120.tar.gz elv_s60w030.tar.gz elv_s60e150.tar.gz ; do 
wget --user=flowdirection  --password=testdirection   http://hydro.iis.u-tokyo.ac.jp/~yamadai/GlobalDir/distribute/v0.2/$file 
tar zxf $file ; rm  -f  $file 

export file 
export filename=$(basename $file  .tar.gz  )

ls /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/RIVER_NETWORK_MERIT/elv/$filename/*_elv.tif | xargs -n 1 -P 12  bash -c $' 
tifname=$(basename $1 )
gdal_translate  -a_nodata 247 -co COMPRESS=DEFLATE  -co ZLEVEL=9   -a_ullr $(getCorners4Gtranslate $1 | awk \'{  printf ("%.0f %.0f %.0f %.0f " ,  $1 , $2 , $3 , $4 )  }\' )  $1 $MERIT/elv/$tifname 
' _ 

rm -f $MERIT/elv/$filename
done

gdalbuildvrt   -overwrite  -srcnodata -9999 -vrtnodata -9999    $MERIT/elv/all_tif.vrt $MERIT/elv/*_elv.tif 
rm -fr  /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/RIVER_NETWORK_MERIT/elv/elv_*
rm -fr  /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/RIVER_NETWORK_MERIT/elv/*.tar.gz


# Upstream Drainage Area
cd /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/RIVER_NETWORK_MERIT/upa

for file in upa_n60w180.tar.gz upa_n60e000.tar.gz upa_n60w150.tar.gz upa_n60e030.tar.gz upa_n60w120.tar.gz upa_n60e060.tar.gz upa_n60w090.tar.gz upa_n60e090.tar.gz upa_n60w060.tar.gz upa_n60e120.tar.gz upa_n60w030.tar.gz upa_n60e150.tar.gz upa_n30w180.tar.gz upa_n30e000.tar.gz upa_n30w150.tar.gz upa_n30e030.tar.gz upa_n30w120.tar.gz upa_n30e060.tar.gz upa_n30w090.tar.gz upa_n30e090.tar.gz upa_n30w060.tar.gz upa_n30e120.tar.gz upa_n30w030.tar.gz upa_n30e150.tar.gz upa_n00w180.tar.gz upa_n00e000.tar.gz n00w150 upa_n00e030.tar.gz upa_n00w120.tar.gz upa_n00e060.tar.gz upa_n00w090.tar.gz upa_n00e090.tar.gz upa_n00w060.tar.gz upa_n00e120.tar.gz upa_n00w030.tar.gz upa_n00e150.tar.gz upa_s30w180.tar.gz upa_s30e000.tar.gz upa_s30w150.tar.gz upa_s30e030.tar.gz upa_s30w120.tar.gz upa_s30e060.tar.gz upa_s30w090.tar.gz upa_s30e090.tar.gz upa_s30w060.tar.gz upa_s30e120.tar.gz upa_s30w030.tar.gz upa_s30e150.tar.gz upa_s60w180.tar.gz upa_s60e000.tar.gz upa_s60e030.tar.gz upa_s60e060.tar.gz upa_s60w090.tar.gz upa_s60e090.tar.gz upa_s60w060.tar.gz upa_s60e120.tar.gz upa_s60w030.tar.gz upa_s60e150.tar.gz ; do 
wget --user=flowdirection  --password=testdirection   http://hydro.iis.u-tokyo.ac.jp/~yamadai/GlobalDir/distribute/v0.2/$file 

tar zxf $file ;   rm  -f  $file 

export file 
export filename=$(basename $file  .tar.gz  )

ls /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/RIVER_NETWORK_MERIT/upa/$filename/*_upa.tif | xargs -n 1 -P 12  bash -c $' 
tifname=$(basename $1 )
gdal_translate  -a_nodata 247 -co COMPRESS=DEFLATE  -co ZLEVEL=9   -a_ullr $(getCorners4Gtranslate $1 | awk \'{  printf ("%.0f %.0f %.0f %.0f " ,  $1 , $2 , $3 , $4 )  }\' )  $1 $MERIT/upa/$tifname 
' _ 

rm -f $MERIT/upa/$filename
done

gdalbuildvrt   -overwrite  -srcnodata -9999 -vrtnodata -9999   $MERIT/upa/all_tif.vrt $MERIT/upa/*_upa.tif 
rm -fr  /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/RIVER_NETWORK_MERIT/upa/upa_*
rm -fr  /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/RIVER_NETWORK_MERIT/upa/*.tar.gz


exit


# Upstream Grid Number  

cd /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/RIVER_NETWORK_MERIT/upg

for file in upg_n60w180.tar.gz upg_n60e000.tar.gz upg_n60w150.tar.gz upg_n60e030.tar.gz upg_n60w120.tar.gz upg_n60e060.tar.gz upg_n60w090.tar.gz upg_n60e090.tar.gz upg_n60w060.tar.gz upg_n60e120.tar.gz upg_n60w030.tar.gz upg_n60e150.tar.gz upg_n30w180.tar.gz upg_n30e000.tar.gz upg_n30w150.tar.gz upg_n30e030.tar.gz upg_n30w120.tar.gz upg_n30e060.tar.gz upg_n30w090.tar.gz upg_n30e090.tar.gz upg_n30w060.tar.gz upg_n30e120.tar.gz upg_n30w030.tar.gz upg_n30e150.tar.gz upg_n00w180.tar.gz upg_n00e000.tar.gz n00w150 upg_n00e030.tar.gz upg_n00w120.tar.gz upg_n00e060.tar.gz upg_n00w090.tar.gz upg_n00e090.tar.gz upg_n00w060.tar.gz upg_n00e120.tar.gz upg_n00w030.tar.gz upg_n00e150.tar.gz upg_s30w180.tar.gz upg_s30e000.tar.gz upg_s30w150.tar.gz upg_s30e030.tar.gz upg_s30w120.tar.gz upg_s30e060.tar.gz upg_s30w090.tar.gz upg_s30e090.tar.gz upg_s30w060.tar.gz upg_s30e120.tar.gz upg_s30w030.tar.gz upg_s30e150.tar.gz upg_s60w180.tar.gz upg_s60e000.tar.gz upg_s60e030.tar.gz upg_s60e060.tar.gz upg_s60w090.tar.gz upg_s60e090.tar.gz upg_s60w060.tar.gz upg_s60e120.tar.gz upg_s60w030.tar.gz upg_s60e150.tar.gz ; do 
wget --user=flowdirection  --password=testdirection   http://hydro.iis.u-tokyo.ac.jp/~yamadai/GlobalDir/distribute/v0.2/$file 
tar zxf $file  ;   rm  -f  $file 

export file 
export filename=$(basename $file  .tar.gz  )

ls /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/RIVER_NETWORK_MERIT/upg/$filename/*_upg.tif | xargs -n 1 -P 12  bash -c $' 
tifname=$(basename $1 )
gdal_translate  -a_nodata 247 -co COMPRESS=DEFLATE  -co ZLEVEL=9   -a_ullr $(getCorners4Gtranslate $1 | awk \'{  printf ("%.0f %.0f %.0f %.0f " ,  $1 , $2 , $3 , $4 )  }\' )  $1 $MERIT/upg/$tifname 
' _ 

rm -f $MERIT/upg/$filename
done

gdalbuildvrt    -srcnodata -9999 -vrtnodata -9999    -overwrite $MERIT/upg/all_tif.vrt $MERIT/upg/*_upg.tif 
rm -fr  /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/RIVER_NETWORK_MERIT/upg/upg_*
rm -fr  /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/RIVER_NETWORK_MERIT/upg/*.tar.gz


# River Channel Width
cd /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/RIVER_NETWORK_MERIT/wth

for file in wth_n60w180.tar.gz wth_n60e000.tar.gz wth_n60w150.tar.gz wth_n60e030.tar.gz wth_n60w120.tar.gz wth_n60e060.tar.gz wth_n60w090.tar.gz wth_n60e090.tar.gz wth_n60w060.tar.gz wth_n60e120.tar.gz wth_n60w030.tar.gz wth_n60e150.tar.gz wth_n30w180.tar.gz wth_n30e000.tar.gz wth_n30w150.tar.gz wth_n30e030.tar.gz wth_n30w120.tar.gz wth_n30e060.tar.gz wth_n30w090.tar.gz wth_n30e090.tar.gz wth_n30w060.tar.gz wth_n30e120.tar.gz wth_n30w030.tar.gz wth_n30e150.tar.gz wth_n00w180.tar.gz wth_n00e000.tar.gz n00w150 wth_n00e030.tar.gz wth_n00w120.tar.gz wth_n00e060.tar.gz wth_n00w090.tar.gz wth_n00e090.tar.gz wth_n00w060.tar.gz wth_n00e120.tar.gz wth_n00w030.tar.gz wth_n00e150.tar.gz wth_s30w180.tar.gz wth_s30e000.tar.gz wth_s30w150.tar.gz wth_s30e030.tar.gz wth_s30w120.tar.gz wth_s30e060.tar.gz wth_s30w090.tar.gz wth_s30e090.tar.gz wth_s30w060.tar.gz wth_s30e120.tar.gz wth_s30w030.tar.gz wth_s30e150.tar.gz wth_s60w180.tar.gz wth_s60e000.tar.gz wth_s60e030.tar.gz wth_s60e060.tar.gz wth_s60w090.tar.gz wth_s60e090.tar.gz wth_s60w060.tar.gz wth_s60e120.tar.gz wth_s60w030.tar.gz wth_s60e150.tar.gz ; do 
wget --user=flowupgection  --password=testupgection   http://hydro.iis.u-tokyo.ac.jp/~yamadai/GlobalUpg/distribute/v0.2/$file 
tar zxf $file ;   rm  -f  $file 

export file 
export filename=$(basename $file  .tar.gz  )

ls /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/RIVER_NETWORK_MERIT/wth/$filename/*_wth.tif | xargs -n 1 -P 12  bash -c $' 
tifname=$(basename $1 )
gdal_translate  -a_nodata -9999 -co COMPRESS=DEFLATE  -co ZLEVEL=9   -a_ullr $(getCorners4Gtranslate $1 | awk \'{  printf ("%.0f %.0f %.0f %.0f " ,  $1 , $2 , $3 , $4 )  }\' )  $1 $MERIT/upg/$tifname 
' _ 

rm -f $MERIT/wth/$filename
done

gdalbuildvrt   -overwrite -srcnodata -9999 -vrtnodata -9999  $MERIT/wth/all_tif.vrt $MERIT/wth/*_wth.tif 
rm -fr  /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/RIVER_NETWORK_MERIT/wth/wth_*
rm -fr  /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/RIVER_NETWORK_MERIT/wth/*.tar.gz










