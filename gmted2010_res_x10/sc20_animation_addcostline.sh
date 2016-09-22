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

# correction to have in value in percentage
# cd  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/final/percent 

# for file in geom*_10KMperc_GMTEDmd.tif ; do 
# oft-calc -ot Float32  $file  $(basename $file .tif )_p.tif  <<EOF
# 1
# #1 0.0001 *
# EOF
# done

# multiply for 1000 to have larger number if not the was geting a white png 

# for var in pcurv tcurv dyy dxx ; do 
# cd  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/final/${var}
# oft-calc -ot Float32   ${var}_10KMmd_GMTEDmd.tif ${var}_10KMmd_GMTEDmd_p.tif   <<EOF                                                                            
# 1
# #1 1000 *
# EOF
# oft-calc -ot Float32   ${var}_10KMsd_GMTEDmd.tif ${var}_10KMsd_GMTEDmd_p.tif  <<EOF
# 1
# #1 1000 *
# EOF
# done 


cat $DIR/png/list4png_addcoas.txt  | awk '{ if ($1!="")  print  }'      | xargs -n 1 -P 8 bash -c $' 

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

postscript(paste("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/final/png/",filename,".ps",sep=""),width=16 , height=8  , paper="special" ,  horizo=F  )

paste("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/final/png/",filename,".ps",sep="")

day001=raster(paste(file,sep=""))

ext <- as.vector(extent(day001))
print ("load shapefile")

coast=shapefile("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/final/png/globe_clip.shp" ,  useC=FALSE )

# coast=crop(coast, extent(ext)) 
 
n=100

if ( filename == "elevation_10KMmd_GMTEDmd")    { max=max ; min=min ; des="Elevation - Median"  }   #1
if ( filename == "elevation_10KMsd_GMTEDmd")    { max=400 ; min=min ; des="Elevation - Standard deviation"  }

if ( filename == "elevation_10KMpsd_GMTEDsd") { max=50 ; min=min ; des="Elevation - Pooled standard deviation" }
if ( filename == "elevation_10KMsd_GMTEDsd")  { max=25 ; min=min ; des="Elevation - Standard deviation of the standard deviation" }

if ( filename == "slope_10KMmd_GMTEDmd") { max=15 ; min=min ; des="Slope  - Median"  }        #6
if ( filename == "slope_10KMsd_GMTEDmd") { max=15 ; min=min ; des="Slope - Standard deviation"  }     
if ( filename == "aspectcosine_10KMmd_GMTEDmd") { max=1 ; min=-1 ; des="Aspect Cosine - Median"  } #10
if ( filename == "aspectcosine_10KMsd_GMTEDmd") { max=0.8 ; min=min ; des="Aspect Cosine - Standard deviation"  }       # problem with the -nan
if ( filename == "aspectsine_10KMmd_GMTEDmd") { max=1 ; min=-1 ; des="Aspect Sine - Median"  }
if ( filename == "aspectsine_10KMsd_GMTEDmd") { max=0.8 ; min=min ; des="Aspect Sine - Standard deviation"  }         # problem with the -nan
if ( filename == "eastness_10KMmd_GMTEDmd") { max=0.2 ; min=-0.2 ; des="Eastness - Median"  }   # 14 
if ( filename == "eastness_10KMsd_GMTEDmd") { max=max ; min=min ; des="Eastness - Standard deviation"  }
if ( filename == "northness_10KMmd_GMTEDmd") { max=0.2 ; min=-0.2 ; des="Northness - Median"  }   # 
if ( filename == "northness_10KMsd_GMTEDmd") { max=max ; min=min ; des="Northness - Standard deviation"  }   # 17
#18
if ( filename == "dx_10KMmd_GMTEDmd") { max=0.025 ; min=-0.025 ; des="First order partial derivative (E-W slope) - Median"  }       #  ok 
if ( filename == "dx_10KMsd_GMTEDmd") { max=0.2 ; min=min ; des="First order partial derivative (E-W slope) - Standard deviation"  }    #  ok 
if ( filename == "dxx_10KMmd_GMTEDmd_p") { max=0.05 ; min=-0.05 ; des="Second order partial derivative - Median"  }        # 20   
if ( filename == "dxx_10KMsd_GMTEDmd_p") { max=1.5 ; min=0 ; des="Second order partial derivative - Standard deviation"  }      # 
if ( filename == "dy_10KMmd_GMTEDmd") { max=0.025 ; min=-0.025 ; des="First order partial derivative (N-S slope) - Median"  }       # ok 
if ( filename == "dy_10KMsd_GMTEDmd") { max=0.3 ; min=min ; des="First order partial derivative (N-S slope) - Standard deviation"  }   # 23  ok 
if ( filename == "dyy_10KMmd_GMTEDmd_p") { max=0.05 ; min=-0.05 ; des="Second order partial derivative - Median"  }         #   
if ( filename == "dyy_10KMsd_GMTEDmd_p") { max=1.5 ; min=min ; des="Second order partial derivative - Standard deviation"  }     # 25 
if ( filename == "pcurv_10KMmd_GMTEDmd_p") { max=0.02 ; min=-0.02 ; des="Profile curvature - Median"  }   #   mesures the topographic convergence and divergence along the flow line , the rate of chbge if slope along the down the flow line 
if ( filename == "pcurv_10KMsd_GMTEDmd_p") { max=1 ; min=0 ; des="Profile curvature - Standard deviation"  } 
if ( filename == "tcurv_10KMmd_GMTEDmd_p") { max=0.02 ; min=-0.02 ; des="Tangential curvature - Median"  }   # (plan curvature * sine of the slope) the rate of change of aspect along the countour 
if ( filename == "tcurv_10KMsd_GMTEDmd_p") { max=1 ; min=min ; des="Tangential curvature - Standard deviation"  } 
# 31
if ( filename == "roughness_10KMmd_GMTEDmd") { max=200 ; min=min ; des="Roughness - Median"  }
if ( filename == "roughness_10KMsd_GMTEDmd") { max=200 ; min=min ; des="Roughness - Standard deviation"  }
if ( filename == "tpi_10KMmd_GMTEDmd") { max=2 ; min=-2 ; des="Topographic Position Index - Median "  }
if ( filename == "tpi_10KMsd_GMTEDmd") { max=60 ; min=min ; des="Topographic Position Index- Standard deviation"  }
if ( filename == "tri_10KMmd_GMTEDmd") { max=60 ; min=min ; des="Terrain Ruggedness Index - Median"  }
if ( filename == "tri_10KMsd_GMTEDmd") { max=60 ; min=min ; des="Terrain Ruggedness Index - Standard deviation"  }
if ( filename == "vrm_10KMmd_GMTEDmd") { max=0.004 ; min=0 ; des="Vector Ruggedness Measure - Median"  }
if ( filename == "vrm_10KMsd_GMTEDmd") { max=0.005 ; min=0 ; des="Vector Ruggedness Measure - Standard deviation"  }
# 39 
if ( filename == "geomflat_10KMperc_GMTEDmd_p") { max=max ; min=min ; des="Flat geomorphological landform - Percentage"  }
if ( filename == "geompeak_10KMperc_GMTEDmd_p") { max=max ; min=min ; des="Peak geomorphological landform - Percentage"  }
if ( filename == "geomridge_10KMperc_GMTEDmd_p") { max=max ; min=min ; des="Ridge geomorphological landform - Percentage"  }
if ( filename == "geomshoulder_10KMperc_GMTEDmd_p") { max=max ; min=min ; des="Shoulder geomorphological landform - Percentage"  }
if ( filename == "geomspur_10KMperc_GMTEDmd_p") { max=max ; min=min ; des="Spur geomorphological landform - Percentage"  }
if ( filename == "geomfootslope_10KMperc_GMTEDmd_p") { max=max ; min=min ; des="Slope geomorphological landform - Percentage"  }
if ( filename == "geomhollow_10KMperc_GMTEDmd_p") { max=max ; min=min ; des="Hollow geomorphological landform - Percentage"  }
if ( filename == "geomslope_10KMperc_GMTEDmd_p") { max=max ; min=min ; des="Footslope geomorphological landform - Percentage"  }
if ( filename == "geomvalley_10KMperc_GMTEDmd_p") { max=max ; min=min ; des="Valley geomorphological landform - Percentage"  }
if ( filename == "geompit_10KMperc_GMTEDmd_p") { max=max ; min=min ; des="Pit geomorphological landform - Percentage"  }
if ( filename == "geom_10KMmaj_GMTEDmd")         { max=max ; min=min ; des="Majority of geomorphological landforms"  }
if ( filename == "geom_10KMcount_GMTEDmd")       { max=max ; min=min ; des="Count of geomorphological landforms"  }
if ( filename == "geom_10KMsha_GMTEDmd")         { max=max ; min=min ; des="Shannon index of geomorphological landforms"  }  
if ( filename == "geom_10KMent_GMTEDmd")         { max=max ; min=min ; des="Entropy index of geomorphological landforms"  }
if ( filename == "geom_10KMuni_GMTEDmd")         { max=max ; min=min ; des="Uniformity index of geomorphological landforms"  }

at=seq(min,max,length=n)
colR=colorRampPalette(c("blue","green","yellow", "orange" , "red", "brown", "black" ))
 
cols=colR(n)

#  "#0000FF" "#000FEF" "#001EE0" "#002ED0" "#003DC1" "#004DB1" "#005CA2" "#006C92" "#007B83" "#008B73" "#009A64" "#00AA54" "#00B945" "#00C836" "#00D826" "#00E717" "#00F707" "#07FF00" "#17FF00" "#26FF00" "#36FF00" "#45FF00" "#55FF00" "#64FF00" "#73FF00" "#83FF00" "#92FF00" "#A2FF00" "#B1FF00" "#C1FF00" "#D0FF00" "#E0FF00" "#EFFF00" "#FFFE00" "#FFF900" "#FFF400" "#FFEE00" "#FFE900" "#FFE300" "#FFDE00" "#FFD800" "#FFD300" "#FFCD00" "#FFC800" "#FFC300" "#FFBD00" "#FFB800" "#FFB200" "#FFAD00" "#FFA700" "#FF9F00" "#FF9500" "#FF8B00" "#FF8200" "#FF7700" "#FF6D00" "#FF6300" "#FF5900" "#FF4F00" "#FF4500" "#FF3B00" "#FF3100" "#FF2700" "#FF1D00" "#FF1300" "#FF0900" "#FE0000" "#F90202" "#F40505" "#EE0707" "#E90A0A" "#E30C0C" "#DE0F0F" "#D81111" "#D31414" "#CD1616" "#C81919"  "#C21C1C" "#BD1E1E" "#B82121" "#B22323" "#AD2626" "#A72828" "#9F2828" "#952626" "#8B2323" "#812121" "#771E1E" "#6D1B1B" "#631919" "#591616" "#4F1414" "#451111" "#3B0F0F" "#310C0C" "#270A0A" "#1D0707" "#130505" "#090202" "#000000"

#   "0000FF,000FEF,001EE0,002ED0,003DC1,004DB1,005CA2,006C92,007B83,008B73,009A64,00AA54,00B945,00C836,00D826,00E717,00F707,07FF00,17FF00,26FF00,36FF00,45FF00,55FF00,64FF00,73FF00,83FF00,92FF00,A2FF00,B1FF00,C1FF00,D0FF00,E0FF00,EFFF00,FFFE00,FFF900,FFF400,FFEE00,FFE900,FFE300,FFDE00,FFD800,FFD300,FFCD00,FFC800,FFC300,FFBD00,FFB800,FFB200,FFAD00,FFA700,FF9F00,FF9500,FF8B00,FF8200,FF7700,FF6D00,FF6300,FF5900,FF4F00,FF4500,FF3B00,FF3100,FF2700,FF1D00,FF1300,FF0900,FE0000,F90202,F40505,EE0707,E90A0A,E30C0C,DE0F0F,D81111,D31414,CD1616,C81919,C21C1C,BD1E1E,B82121,B22323,AD2626,A72828,9F2828,952626,8B2323,812121,771E1E,6D1B1B,631919,591616,4F1414,451111,3B0F0F,310C0C,270A0A,1D0707,130505,090202,000000"

res=1e6 # res=1e4 for testing and res=1e6 for the final product
greg=list(ylim=c(-56,84),xlim=c(-180,180))

par(cex.axis=2, cex.lab=2, cex.main=2, cex.sub=2)

day001[day001>max] <- max
day001[day001<min] <- min

print ( levelplot(day001,col.regions=colR(n),  scales=list(cex=1.5) ,   cuts=99,at=at,colorkey=list(space="right",adj=2 , labels=list( cex=1.5)), panel=panel.levelplot.raster,   margin=T,maxpixels=res,ylab="", xlab=list(paste(des,sep="") , cex=1.5 , space="left" ) ,useRaster=T ) + layer(sp.polygons(coast ,  fill="white" )  ) )

rmr(day001) # really  remove raster files, this will delete the temporary file
dev.off() 

EOF


convert -flatten -density 300  $DIR/png/$filename.ps  $DIR/png/$filename.png
ps2epsi    $DIR/png/$filename.ps  $DIR/png/$filename.eps
' _ 

exit 




# forms animation 

for file  in geomorphic_class*_GMTED2010_md_km10p.png   ; do composite -geometry +172+450 \(  class.png -resize 54% \) $file class_$file ; done
convert   -delay 500   -loop 0 class_geomorphic_class*_GMTED2010_md_km10p.png class_geomorphic_class_GMTED2010_md_km10p.gif


convert -delay 500 -loop 0 roughness_md_GMTED2010_md_km10.png  roughness_sd_GMTED2010_md_km10.png tpi_md_GMTED2010_md_km10.png  tpi_sd_GMTED2010_md_km10.png tri_md_GMTED2010_md_km10.png tri_sd_GMTED2010_md_km10.png vrm_md_GMTED2010_md_km10.png vrm_sd_GMTED2010_md_km10.png roughness.gif

convert   -delay 500   -loop 0 pcurv_md_GMTED2010_md_km10p.png pcurv_sd_GMTED2010_md_km10p.png tcurv_md_GMTED2010_md_km10p.png  tcurv_sd_GMTED2010_md_km10p.png dx_md_GMTED2010_md_km10.png  dx_sd_GMTED2010_md_km10.png  dy_md_GMTED2010_md_km10.png  dy_sd_GMTED2010_md_km10.png curvature.gif 

convert   -delay 500   -loop 0 elevation_md_GMTED2010_md_km10.png elevation_range_GMTED2010_mxmi_km10.png  elevation_sd_GMTED2010_md_km10.png elevation_sd_GMTED2010_sd_km10.png elevation_psd_GMTED2010_sd_km10.png     elevation_cv_GMTED2010_mnsd_km10.png elevation_cv_GMTED2010_mnpsd_km10.png elevation.gif

