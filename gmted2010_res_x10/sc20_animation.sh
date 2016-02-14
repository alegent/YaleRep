

#PBS -S /bin/bash 
#PBS -q fas_devel
#PBS -l walltime=4:00:00 
#PBS -l nodes=1:ppn=8
#PBS -V
#PBS -o /scratch/fas/sbsc/ga254/stdout
#PBS -e /scratch/fas/sbsc/ga254/stderr

module load Apps/R/3.0.2 

# lista interna di r fatta con quest 
# for file in $(cat  list4png.txt ) ; do echo "if ( filename == \""$(basename $file .tif)\"")" "{ max=max ; min=min ; des=\"\"  }"  ; done 

export DIR=/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/final

#ls $DIR/*/*_md_GMTED2010_md_km10.tif  $DIR/*/*_sd_GMTED2010_md_km10.tif   $DIR/*/geomorphic_*_GMTED2010_md_km10.tif     $DIR/derived_var/*km10.tif   | xargs -n 1 -P 8 bash -c $' 

# correction to have in value in percentage
# cd  $DIR
# for file in geomorphic_class*_GMTED2010_md_km100.tif ; do 
# oft-calc -ot Float32  $file  $(baename $file .tif )p.tif  <<EOF
# 1
# #1 0.0001 *
# EOF
# done

# multiply for 1000 to have larger number if not the was geting a white png 

# for var in pcurv tcurv dyy dxx ; do 
# cd  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/final/${var}
# oft-calc -ot Float32   ${var}_md_GMTED2010_md_km10.tif ${var}_md_GMTED2010_md_km10p.tif   <<EOF                                                                            
# 1
# #1 1000 *
# EOF
# oft-calc -ot Float32   ${var}_sd_GMTED2010_md_km10.tif ${var}_sd_GMTED2010_md_km10p.tif   <<EOF
# 1
# #1 1000 *
# EOF
# done 

cat $DIR/png/list4png.txt | awk '{ if ($1!="") { if (NR>-1  && NR<7) print } }'   | xargs -n 1 -P 8 bash -c $' 


export file=$1
export filename=$(basename $file .tif)

export min=$(gdalinfo -mm $file   | grep "Comp" | awk \'{ gsub ("[=,]"," ") ; print $3   }\')
export max=$(gdalinfo -mm $file   | grep "Comp" | awk \'{ gsub ("[=,]"," ") ; print $4   }\')


R --vanilla --no-readline   -q  <<'EOF'


# source ("/home/fas/sbsc/ga254/scripts/AE_C6_MYD04_L2/sc4_animationR.sh")
.libPaths( c( .libPaths(), "/home/fas/sbsc/ga254/R/x86_64-unknown-linux-gnu-library/3.0") )

library(raster)
library(lattice , lib.loc ="/home/fas/sbsc/ga254/R/x86_64-unknown-linux-gnu-library/3.0")
library(rasterVis)
library(foreach)

#  gdal_translate  -co COMPRESS=LZW -co ZLEVEL=9  -ot Int32  -a_nodata -9999   integration001.tif    integration001a.tif

file = Sys.getenv(c("file"))
filename = Sys.getenv(c("filename"))
max = as.numeric(Sys.getenv(c("max")))
min = as.numeric(Sys.getenv(c("min")))


rmr=function(x){
## function to truly delete raster and temporary files associated with them
if(class(x)=="RasterLayer"&grepl("^/tmp",x@file@name)&fromDisk(x)==T){
file.remove(x@file@name,sub("grd","gri",x@file@name))
rm(x)
}
}


path = "/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/final"

# for parallel
# you can use a foreach to do it in parallel too, if you like

# foreach(file=files.list) %dopar%{

## not sure exactly what this does, but there is basename(file) too...

png(paste("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/final/png/",filename,".png",sep=""),width=2000,height=900)

paste("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/final/png/",filename,".png",sep="")

day001=raster(paste(file,sep=""))

day001


 
n=100


if ( filename == "elevation_md_GMTED2010_md_km10")    { max=max ; min=min ; des="Elevation - Median"  }   #1
if ( filename == "elevation_sd_GMTED2010_md_km10")    { max=400 ; min=min ; des="Elevation - Standard deviation"  }
if ( filename == "elevation_cv_GMTED2010_mnpsd_km10") { max=0.2 ; min=-0.2 ; des="Elevation - Coefficient of variation"  }   #3
if ( filename == "elevation_cv_GMTED2010_mnsd_km10")  { max=0.4 ; min=-0.2 ; des="Elevation - Coefficient of variation"  }
if ( filename == "elevation_range_GMTED2010_mxmi_km10") { max=3000 ; min=min ; des="Elevation - Range"  }

if ( filename == "elevation_psd_GMTED2010_sd_km10") { max=50 ; min=min ; des="Elevation - Pooled standard deviation" }
if ( filename == "elevation_sd_GMTED2010_sd_km10")  { max=25 ; min=min ; des="Elevation - Standard deviation of the standard deviation" }

if ( filename == "slope_md_GMTED2010_md_km10") { max=15 ; min=min ; des="Slope  - Median"  }        #6
if ( filename == "slope_sd_GMTED2010_md_km10") { max=15 ; min=min ; des="Slope - Standard deviation"  }     
if ( filename == "slope_cv_GMTED2010_mnsd_km10") { max=1.25 ; min=min ; des="Slope - Coefficient of variation"  }    #8
if ( filename == "slope_range_GMTED2010_mxmi_km10") { max=50 ; min=min ; des="Slope - Range"  }
if ( filename == "aspect-cosine_md_GMTED2010_md_km10") { max=1 ; min=-1 ; des="Aspect Cosine - Median"  } #10
if ( filename == "aspect-cosine_sd_GMTED2010_md_km10") { max=min ; min=min ; des="Aspect Cosine - Standard deviation"  }       # problem with the -nan
if ( filename == "aspect-sine_md_GMTED2010_md_km10") { max=1 ; min=-1 ; des="Aspect Sine - Median"  }
if ( filename == "aspect-sine_sd_GMTED2010_md_km10") { max=max ; min=min ; des="Aspect Sine - Standard deviation"  }         # problem with the -nan
if ( filename == "eastness_md_GMTED2010_md_km10") { max=0.2 ; min=-0.2 ; des="Eastness - Median"  }   # 14 
if ( filename == "eastness_sd_GMTED2010_md_km10") { max=max ; min=min ; des="Eastness - Standard deviation"  }
if ( filename == "northness_md_GMTED2010_md_km10") { max=0.2 ; min=-0.2 ; des="Northness - Median"  }   # 
if ( filename == "northness_sd_GMTED2010_md_km10") { max=max ; min=min ; des="Northness - Standard deviation"  }   # 17
#18
if ( filename == "dx_md_GMTED2010_md_km10") { max=0.025 ; min=-0.025 ; des="First order partial derivative (E-W slope) - Median"  }       #  ok 
if ( filename == "dx_sd_GMTED2010_md_km10") { max=0.2 ; min=min ; des="First order partial derivative (E-W slope) - Standard deviation"  }    #  ok 
if ( filename == "dxx_md_GMTED2010_md_km10p") { max=0.05 ; min=-0.05 ; des="Second order partial derivative - Median"  }        # 20   
if ( filename == "dxx_sd_GMTED2010_md_km10p") { max=2 ; min=0 ; des="Second order partial derivative - Standard deviation"  }      # 
if ( filename == "dy_md_GMTED2010_md_km10") { max=0.025 ; min=-0.025 ; des="First order partial derivative (N-S slope) - Median"  }       # ok 
if ( filename == "dy_sd_GMTED2010_md_km10") { max=0.3 ; min=min ; des="First order partial derivative (N-S slope) - Standard deviation"  }   # 23  ok 
if ( filename == "dyy_md_GMTED2010_md_km10p") { max=0.05 ; min=-0.05 ; des="Second order partial derivative - Median"  }         #   
if ( filename == "dyy_sd_GMTED2010_md_km10p") { max=2 ; min=min ; des="Second order partial derivative - Standard deviation"  }     # 25 
if ( filename == "pcurv_md_GMTED2010_md_km10p") { max=0.02 ; min=-0.02 ; des="Profile curvature - Median"  }   #   mesures the topographic convergence and divergence along the flow line , the rate of chbge if slope along the down the flow line 
if ( filename == "pcurv_sd_GMTED2010_md_km10p") { max=1 ; min=0 ; des="Profile curvature - Standard deviation"  } 
if ( filename == "tcurv_md_GMTED2010_md_km10p") { max=0.02 ; min=-0.02 ; des="Tangential curvature - Median"  }   # (plan curvature * sine of the slope) the rate of change of aspect along the countour 
if ( filename == "tcurv_sd_GMTED2010_md_km10p") { max=1 ; min=min ; des="Tangential curvature - Standard deviation"  } 
# 31
if ( filename == "roughness_md_GMTED2010_md_km10") { max=200 ; min=min ; des="Roughness - Median"  }
if ( filename == "roughness_sd_GMTED2010_md_km10") { max=200 ; min=min ; des="Roughness - Standard deviation"  }
if ( filename == "tpi_md_GMTED2010_md_km10") { max=2 ; min=-2 ; des="Topographic Position Index - Median "  }
if ( filename == "tpi_sd_GMTED2010_md_km10") { max=60 ; min=min ; des="Topographic Position Index- Standard deviation"  }
if ( filename == "tri_md_GMTED2010_md_km10") { max=60 ; min=min ; des="Terrain Ruggedness Index - Median"  }
if ( filename == "tri_sd_GMTED2010_md_km10") { max=60 ; min=min ; des="Terrain Ruggedness Index - Standard deviation"  }
if ( filename == "vrm_md_GMTED2010_md_km10") { max=-0.1225 ; min=min ; des="Vector Ruggedness Measure - Median"  }
if ( filename == "vrm_sd_GMTED2010_md_km10") { max=0.005 ; min=min ; des="Vector Ruggedness Measure - Standard deviation"  }
# 39 
if ( filename == "geomorphic_class1_GMTED2010_md_km10p") { max=max ; min=min ; des="Flat geomorphic landform - Percentage"  }
if ( filename == "geomorphic_class2_GMTED2010_md_km10p") { max=max ; min=min ; des="Peak geomorphic landform - Percentage"  }
if ( filename == "geomorphic_class3_GMTED2010_md_km10p") { max=max ; min=min ; des="Ridge geomorphic landform - Percentage"  }
if ( filename == "geomorphic_class4_GMTED2010_md_km10p") { max=max ; min=min ; des="Shoulder geomorphic landform - Percentage"  }
if ( filename == "geomorphic_class5_GMTED2010_md_km10p") { max=max ; min=min ; des="Spur geomorphic landform - Percentage"  }
if ( filename == "geomorphic_class6_GMTED2010_md_km10p") { max=max ; min=min ; des="Slope geomorphic landform - Percentage"  }
if ( filename == "geomorphic_class7_GMTED2010_md_km10p") { max=max ; min=min ; des="Hollow geomorphic landform - Percentage"  }
if ( filename == "geomorphic_class8_GMTED2010_md_km10p") { max=max ; min=min ; des="Footslope geomorphic landform - Percentage"  }
if ( filename == "geomorphic_class9_GMTED2010_md_km10p") { max=max ; min=min ; des="Valley geomorphic landform - Percentage"  }
if ( filename == "geomorphic_class10_GMTED2010_md_km10p") { max=max ; min=min ; des="Pit geomorphic landform - Percentage"  }

if ( filename == "geomorphic_majority_GMTED2010_md_km10") { max=max ; min=min ; des="Majority of geomorphic landform"  }
if ( filename == "geomorphic_count_GMTED2010_md_km10")    { max=max ; min=min ; des="Count of geomorphic landform"  }
if ( filename == "geomorphic_shannon_GMTED2010_md_km10")  { max=max ; min=min ; des="Shanon index of geomorphic landform"  }
if ( filename == "geomorphic_ent_GMTED2010_md_km10")      { max=max ; min=min ; des="Entropy index of geomorphic landform"  }
if ( filename == "geomorphic_uni_GMTED2010_md_km10")      { max=max ; min=min ; des="Uniformity index of geomorphic landform"  }

at=seq(min,max,length=n)
colR=colorRampPalette(c("blue","green","yellow", "orange" , "red", "brown", "black" ))
 
cols=colR(n)
res=1e6 # res=1e4 for testing and res=1e6 for the final product
greg=list(ylim=c(-56,84),xlim=c(-180,180))

par(cex.axis=2, cex.lab=2, cex.main=2, cex.sub=2)

day001[day001>max] <- max
day001[day001<min] <- min

print ( levelplot(day001,col.regions=colR(n),  scales=list(cex=2) ,   cuts=99,at=at,colorkey=list(space="right",adj=2 , labels=list( cex=2.5)), panel=panel.levelplot.raster,   margin=T,maxpixels=res,ylab="", xlab=list(paste(des,sep="") , cex=3 , space="left" ) ,useRaster=T)    )

rmr(day001) # really  remove raster files, this will delete the temporary file
dev.off() 

EOF


' _ 

exit 

cd /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/final/png 

# forms animation 

for file  in geomorphic_class*_GMTED2010_md_km10p.png   ; do composite -geometry +172+450 \(  class.png -resize 54% \) $file class_$file ; done
convert   -delay 500   -loop 0 class_geomorphic_class*_GMTED2010_md_km10p.png class_geomorphic_class_GMTED2010_md_km10p.gif


convert -delay 500 -loop 0 roughness_md_GMTED2010_md_km10.png  roughness_sd_GMTED2010_md_km10.png tpi_md_GMTED2010_md_km10.png  tpi_sd_GMTED2010_md_km10.png tri_md_GMTED2010_md_km10.png tri_sd_GMTED2010_md_km10.png vrm_md_GMTED2010_md_km10.png vrm_sd_GMTED2010_md_km10.png roughness.gif

convert   -delay 500   -loop 0 pcurv_md_GMTED2010_md_km10p.png pcurv_sd_GMTED2010_md_km10p.png tcurv_md_GMTED2010_md_km10p.png  tcurv_sd_GMTED2010_md_km10p.png dx_md_GMTED2010_md_km10.png  dx_sd_GMTED2010_md_km10.png  dy_md_GMTED2010_md_km10.png  dy_sd_GMTED2010_md_km10.png curvature.gif 

convert   -delay 500   -loop 0 elevation_md_GMTED2010_md_km10.png elevation_range_GMTED2010_mxmi_km10.png  elevation_sd_GMTED2010_md_km10.png elevation_sd_GMTED2010_sd_km10.png elevation_psd_GMTED2010_sd_km10.png     elevation_cv_GMTED2010_mnsd_km10.png elevation_cv_GMTED2010_mnpsd_km10.png elevation.gif

