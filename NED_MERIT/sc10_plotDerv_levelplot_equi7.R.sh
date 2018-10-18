#!/bin/sh
#SBATCH -p scavenge 
#SBATCH -n 1 -c 1 -N 1 
#SBATCH -t 24:00:00
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc10_plotDerv_levelplot_equi7.R.%J.out
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc10_plotDerv_levelplot_equi7.R.%J.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email
#SBATCH -J sc10_plotDerv_levelplot_equi7.R.sh

# bash /gpfs/home/fas/sbsc/ga254/scripts/NED_MERIT/sc10_plotDerv_levelplot_equi7.R.sh

module load Apps/R/3.3.2-generic

cd /gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NED_MERIT/

# gdal_translate -projwin  7200000 5400000 7210000 5390000   /gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/MERIT/equi7/dem/NA/NA_072_048.tif /tmp/test.tif 

R  --vanilla --no-readline   -q  <<EOF

rm(list = ls())

library(rgdal)
library(raster)
library(ggplot2)
library(gridExtra)

# require(rasterVis)

# 34 spazio sopra e sotto 
# 35 spazio sopra e sotto ancora piu largo del 34
# 33 piccolo spazio a destra e sinitstra 

#  x pixel number 120
#  y pixel number 81

e = extent ( 7500000 , 7520000 , 5081600 , 5100000 ) 

elev_M = raster ("/gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/MERIT/equi7/dem/NA/NA_072_048.tif") 
elev_M = crop   (elev_M , e)

elev_N = raster ("/gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NED/input_tif/NA_072_048.tif") 
elev_N = crop   (elev_N , e)

elev_dif = raster ("/gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NED_MERIT/input_tif/tiles/NA_072_048_dif.tif")  
elev_dif = crop   (elev_dif , e)


for ( dir in c("input_tif","roughness","tri","tpi","vrm","tci","spi","slope","pcurv","tcurv","dx","dy","dxx","dyy","dxy","convergence")) { 
     raster  <- raster(paste0( dir,"/tiles/","/NA_072_048.tif") ) 
        raster = crop (raster , e)
        raster[raster == -9999 ] <- NA
 	assign(paste0(dir) , raster  )
}

for ( dir in c("Ew","Nw","sin","cos")) { 
        raster  <- raster(paste0("aspect/tiles/NA_072_048_",dir,".tif") ) 
        raster = crop (raster , e)        
        raster[raster == -9999 ] <- NA
 	assign(paste0(dir) , raster  )
}


print("start to plot")

n=100
colR=colorRampPalette(c("blue","green","yellow", "orange" , "red", "brown", "black" ))
cols=colR(n)

options(scipen=10)
trunc <- function(x, ..., prec = 0) base::trunc(x * 10^prec, ...) / 10^prec

pdf(paste0("/gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NED_MERIT/figure/derivative_all_var_plot_equi7.pdf") , width=6, height=7.5   )
par (oma=c(2,2,2,1) , mar=c(0.4,0.5,1,2) , cex.lab=0.5 , cex=0.6 , cex.axis=0.4  ,   mfrow=c(6,4) ,  xpd=NA    )

for ( dir in c("elev_M","elev_N","elev_cor","elev_dif","input_tif","roughness","tri","tpi","vrm","tci","spi","cos","sin","slope","Ew","Nw","pcurv","tcurv","dx","dy","dxx","dyy","dxy","convergence")){

if ( dir != "elev_cor" ) { 
raster=get(dir)
max=get(dir)@data@max ; min=get(dir)@data@min

if(dir == "elev_M"   ) { des="Elevation MERIT"           ; max=max ; min=min ; at=c( round(min)+1 , round(max) ) ; labels=c( round(min) , round(max) ) ; letter="a" }
if(dir == "elev_N"   ) { des="Elevation 3DEP"          ; max=max ; min=min ; at=c( round(min) , round(max) ) ; labels=c( round(min) , round(max) ) ; letter="b" }
if(dir == "elev_dif" ) { des="Elevation diff.  MERIT - 3DEP" ; max=max ; min=min ; at=c( round(min)+1 , round(max) ) ; labels=c( round(min) , round(max) ) ; letter="d" }
# derivatives 
if(dir == "input_tif" )  { des="Elevation"               ; max=max ; min=min ; at=c( min , max ) ; labels=c( min , max ) ; letter="e" }
if(dir == "roughness" )  { des="Roughness"               ; max=max ; min=min ; at=c( 0.1 , 9.4 ) ; labels=c( 0  , 10  ) ; letter="f" }
if(dir == "tri" )     { des="Terrain roughness index"    ; max=max ; min=min ; at=c( 0.1 , 3.3 ) ; labels=c( 0 , 3.3 ) ; letter="g" }
if(dir == "tpi" )     { des="Topographic position index" ; max=max ; min=min ; at=c( 0.1 , 3.2 ) ; labels=c( 0 , 3.2 ) ; letter="h" }
if(dir == "vrm" )     { des="Vector ruggedness measure"  ; max=max ; min=min ; at=pretty( min : max ) ; labels=pretty( min : max ) ; letter="i" }
if(dir == "tci" )     { des="Compound topographic index" ; max=max ; min=min ; at=c(0.1,0.63)    ; labels=c(0.1,0.6) ; letter="j" }
if(dir == "spi" )     { des="Stream power index"         ; max=max ; min=min ; at=c( 0.1 , 24.5 ) ;  labels=c( 0 , 25  ) ; letter="k" }
if(dir == "cos" )     { des="Aspect cosine"                 ; max=max ; min=min ; at=c( 0.1 , 1.2 ) ; labels=c( 0 , 1.2 ) ; letter="l" } 
if(dir == "sin" )     { des="Aspect sine"                   ; max=max ; min=min ; at=c( 0.1 , 1 ) ; labels=c( 0 , 1 ) ; letter="m" }
if(dir == "slope" )   { des="Slope"                         ; max=max ; min=min ; at=pretty( min : max ) ; labels=pretty( min : max ) ; letter="n" }
if(dir == "Ew" )      { des="Eastness"                      ; max=max ; min=min ; at=pretty( min : max ) ; labels=pretty( min : max ) ; letter="o" }
if(dir == "Nw" )      { des="Northness"                      ; max=max ; min=min ; at=c(min,0.01,0.02,0.03 )  ; labels=c(0,0.01,0.02,0.03 ) ; letter="p" }
if(dir == "pcurv" )    { des="Profile curvature"         ; max=max ; min=min ; at=c(0.00001, 0.00065) ; labels=c(0,formatC(max , format = "e", digits = 1 )) ; letter="q" }
if(dir == "tcurv" )    { des="Tangential curvature"      ; max=max ; min=min ; at=c(0.00001, 0.00065) ; labels=c(0,formatC(max , format = "e", digits = 1 )) ; letter="r" } 
if(dir == "dx" )      { des="1st partial derivative (E-W slope)" ; max=max ; min=min ; at=c(0.00001, 0.035) ; labels=c(0,0.035) ; letter="s" }
if(dir == "dy" )  { des="1st partial derivative (N-S slope)"     ; max=max ; min=min ; at=c(0.00001, 0.045) ; labels=c(0,0.045) ; letter="t" } 
if(dir == "dxx" ) { des="2nd partial derivative (E-W slope)"     ; max=max ; min=min ; at=c(0.00001, 0.00065) ; labels=c(0,formatC(max , format = "e", digits = 1 )) ; letter="u" }
if(dir == "dyy" ) { des="2nd partial derivative (N-S slope)" ; max=max ; min=min ; at=c(0.00001, 0.0003) ; labels=c(0,formatC(max , format = "e", digits = 1 )) ; letter="v" }
if(dir == "dxy" ) { des="2nd partial derivative"  ; max=max ; min=min ; at=c(0,2.5) ; labels=c(0,2.5)  ; letter="w" }
if(dir == "convergence" ) { des="Convergence"     ; max=max ; min=min ; at=c(2,40) ; labels=c(0,40)   ; letter="x" }

raster[raster > max] <- max
raster[raster < min] <- min

print(dir)
print (min) ; print (max)

}

# mgp The margin line (in ‘mex’ units) for the axis title, axis
#           labels and axis line.  Note that ‘mgp[1]’ affects ‘title’
#           whereas ‘mgp[2:3]’ affect ‘axis’.  The default is ‘c(3, 1,
#           0)’.


if ( dir == "elev_cor" ) {
plot( elev_M, elev_N, pch = 16, cex = .1 , xaxt = "n" , yaxt = "n" , main="Elevation 3DEP vs MERIT", cex.main=0.65 , font.main=2 )
text( 493 , 427 , "MERIT (m)" , font=2 ,   xpd=TRUE , cex=0.5 )
axis(side = 1, mgp=c(3,-0.35,0),        , cex.axis=0.56 , at =c(440,460,480), labels =c(440,460,480)  , tck=0)
axis(side = 4, mgp=c(3,0.2,0)  ,  las=2 , cex.axis=0.56 , at =c(440,460,480), labels =c(440,460,480)  , tck=0)
text( 505 , 508 , "c" ,  font=2   ,   xpd=TRUE , cex=1.4 )
text( 504 , 492 , "3DEP (m)"   , font=2 ,  srt=90 ,  xpd=TRUE , cex=0.5 )

}

if (( dir != "elev_cor" ) &&  (  dir != "dxx"   )     ) { 
plot(raster  , col=cols , yaxt="n" , xaxt="n" , xlab="" , ylab="" , main=des  , legend=FALSE  , cex.main=0.65 , font.main=2 )
plot(raster, axis.args=list( at=at , labels=labels , line=-0.68, tck=0 , cex.axis=0.56   ) ,  smallplot=c(0.83,0.87, 0.1,0.8), zlim=c( min, max ) , legend.only=TRUE , legend.width=1, legend.shrink=0.75 , col=cols)
text(-96.99 , 42.405, letter ,  font=2   ,   xpd=TRUE , cex=1.2 )
}

# ( 7500000 , 7520000 , 5081600 , 5100000 ) 

if ( dir == "dxx"   ) { 
plot(raster  , col=cols ,  yaxp=c( 42.30, 42.40 , 4 ) , xaxp=c(-97.10 , -97 , 4 ) , tck=-0.05, cex.axis=0.8 , main=des  , legend=FALSE  , cex.main=0.65 , font.main=2 )
plot(raster, axis.args=list( at=at , labels=labels , line=-0.68, tck=0  , cex.axis=0.56) ,  smallplot=c(0.83,0.87, 0.1,0.8), zlim=c( min, max ) , legend.only=TRUE , legend.width=1, legend.shrink=0.75 , col=cols)
text(7522000 ,5101000 , letter ,  font=2   ,   xpd=TRUE , cex=1.2 )
}
}

dev.off()

q()
EOF



