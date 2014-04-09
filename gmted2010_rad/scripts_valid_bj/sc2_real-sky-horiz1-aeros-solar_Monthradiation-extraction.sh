
# using the shape nsrdb  extract information from the month data radiation dif


export INTIF=/lustre0/scratch/ga254/dem_bj/SOLAR/radiation
export SHPIN=/lustre0/scratch/ga254/dem_bj/SOLAR/shp_in
export SHPOUT=/lustre0/scratch/ga254/dem_bj/SOLAR/shp_out


rm -f $SHPOUT/merge[0-9].*  $SHPOUT/merge1[0-9].*
pkextract -i $INTIF/glob_rad/glob_Hrad_months.tif  -ft Integer   -lt  String -bn globH    -s  $SHPIN/point_nsrdb.shp   -o $SHPOUT/merge1.shp 
pkextract -i $INTIF/glob_rad/glob_HradC_months.tif -ft Integer   -lt  String -bn globHC   -s  $SHPOUT/merge1.shp       -o $SHPOUT/merge2.shp 
pkextract -i $INTIF/glob_rad/glob_HradA_months.tif -ft Integer   -lt  String -bn globHA   -s  $SHPOUT/merge2.shp       -o $SHPOUT/merge3.shp 
pkextract -i $INTIF/glob_rad/glob_HradCA_months.tif -ft Integer  -lt  String -bn globHCA  -s  $SHPOUT/merge3.shp       -o $SHPOUT/merge4.shp 

pkextract -i $INTIF/beam_rad/beam_Hrad_months.tif  -ft Integer   -lt  String -bn beamH    -s  $SHPOUT/merge4.shp       -o $SHPOUT/merge5.shp
pkextract -i $INTIF/beam_rad/beam_HradC_months.tif -ft Integer   -lt  String -bn beamHC   -s  $SHPOUT/merge5.shp       -o $SHPOUT/merge6.shp 
pkextract -i $INTIF/beam_rad/beam_HradA_months.tif -ft Integer   -lt  String -bn beamHA   -s  $SHPOUT/merge6.shp       -o $SHPOUT/merge7.shp 
pkextract -i $INTIF/beam_rad/beam_HradCA_months.tif -ft Integer  -lt  String -bn beamHCA  -s  $SHPOUT/merge7.shp       -o $SHPOUT/merge8.shp 

pkextract -i $INTIF/diff_rad/diff_Hrad_months.tif  -ft Integer   -lt  String -bn diffH    -s  $SHPOUT/merge8.shp       -o $SHPOUT/merge9.shp
pkextract -i $INTIF/diff_rad/diff_HradC_months.tif -ft Integer   -lt  String -bn diffHC   -s  $SHPOUT/merge9.shp       -o $SHPOUT/merge10.shp 
pkextract -i $INTIF/diff_rad/diff_HradA_months.tif -ft Integer   -lt  String -bn diffHA   -s  $SHPOUT/merge10.shp      -o $SHPOUT/merge11.shp 
pkextract -i $INTIF/diff_rad/diff_HradCA_months.tif -ft Integer  -lt  String -bn diffHCA  -s  $SHPOUT/merge11.shp      -o $SHPOUT/merge12.shp 


