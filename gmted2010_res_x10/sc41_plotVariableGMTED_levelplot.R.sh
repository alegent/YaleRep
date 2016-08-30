# source ("/home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc41_plotVariableGMTED_levelplot.R.sh" ) 

rm(list = ls())

AREA = "alps"

require(raster)
require(rgdal)
require(rasterVis)
require(gridExtra)

GMTED="/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/"

e=extent( 8.80, 9.80, 46.57, 47.20)

for ( file in c("tpi","tri","vrm","roughness","slope","aspect-cosine","aspect-sine","eastness","northness" ,"elevation","dx","dxx","dy","dyy","pcurv","tcurv")) {
         file
 	raster  <- raster(paste0(GMTED,"/",AREA,"/",file,"_md_GMTED2010_md_km1.tif")) 
         raster[raster == -9999 ] <- NA
         raster = crop (raster , e)
 	assign(paste0(file,"_GMTED") , raster  )
 }

elevation_psd_GMTED = raster("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/alps/elevation_psd_GMTED2010_sd_km1.tif")
elevation_psd_GMTED = crop (elevation_psd_GMTED , e)
elevation_sd_GMTED  = raster("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/alps/elevation_sd_GMTED2010_md_km1.tif")
elevation_sd_GMTED  = crop (elevation_sd_GMTED , e)

for ( file in c("geomorphic_uni","geomorphic_count","geomorphic_ent","geomorphic_majority","geomorphic_shannon","geomorphic_class3")) {
	raster  <- raster(paste0(GMTED,"/",AREA,"/",file,"_GMTED2010_md_km1.tif"))
        raster = crop (raster , e)
	assign(paste0(file,"_GMTED") , raster  )
}

rm(raster, GMTED , file  , AREA )

aspectcosine_GMTED = get(paste0("aspect-cosine_GMTED"))
aspectsine_GMTED   = get(paste0("aspect-sine_GMTED"))

stack = stack(elevation_GMTED,elevation_sd_GMTED,elevation_psd_GMTED,tpi_GMTED,tri_GMTED,vrm_GMTED,roughness_GMTED,slope_GMTED,aspectcosine_GMTED,aspectsine_GMTED,eastness_GMTED,northness_GMTED,pcurv_GMTED,tcurv_GMTED,dx_GMTED,dxx_GMTED,dy_GMTED,dyy_GMTED,geomorphic_majority_GMTED,geomorphic_class3_GMTED, geomorphic_count_GMTED,geomorphic_shannon_GMTED,geomorphic_uni_GMTED,geomorphic_ent_GMTED)

n=100
colR=colorRampPalette(c("blue","green","yellow", "orange" , "red", "brown", "black" ))
cols=colR(n)

options(scipen=10)
trunc <- function(x, ..., prec = 0) base::trunc(x * 10^prec, ...) / 10^prec

postscript(paste0("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/alps_all_var_plot.ps") ,  paper="special" ,  horizo=F , width=6, height=7.5   )
par (oma=c(2,2,2,1) , mar=c(0.4,0.5,1,2) , cex.lab=0.5 , cex=0.6 , cex.axis=0.4  ,   mfrow=c(6,4) ,  xpd=NA    )

for ( file in c("elevation_GMTED","elevation_sd_GMTED","elevation_psd_GMTED","tpi_GMTED","tri_GMTED","vrm_GMTED","roughness_GMTED","slope_GMTED","aspectcosine_GMTED","aspectsine_GMTED","eastness_GMTED","northness_GMTED","pcurv_GMTED","tcurv_GMTED","dx_GMTED","dxx_GMTED","dy_GMTED","dyy_GMTED","geomorphic_majority_GMTED","geomorphic_class3_GMTED","geomorphic_count_GMTED","geomorphic_shannon_GMTED","geomorphic_uni_GMTED","geomorphic_ent_GMTED") )  { 

raster=get(file)

if(file == "elevation_GMTED" )    {  des="Elevation Median" ; max=get(file)@data@max ; min=get(file)@data@min ; at=pretty( min  : max ) ; labels=pretty( min  : max ) ; letter="(a)" }
if(file == "elevation_sd_GMTED" ) {  des="Elevation St. Dev." ; max=300  ; min=0 ; at=pretty( min  : max ) ; labels=pretty( min  : max )                              ; letter="(b)" }
if(file == "elevation_psd_GMTED") {  des="Elevation Pooled St. Dev."; max=100 ; min=0 ; at=pretty( min  : max ) ; labels=pretty( min  : max )                         ; letter="(c)" }
if(file == "tpi_GMTED" )          {  des="Topographic Position Index" ; max=25 ; min=-25 ; at=pretty( min  : max ) ; labels=pretty( min  : max )                      ; letter="(d)" }

if(file == "tri_GMTED" )          {  des="Terrain Roughness Index"; max=150 ; min=get(file)@data@min ; at=pretty( min  : max ) ; labels=pretty( min  : max )          ; letter="(e)" }
if(file == "vrm_GMTED" )          {  des="Vector Ruggedness Measure" ; max=0.08 ; min=0 ;  at=c(0,0.02,0.04,0.06,0.08) ; labels=c(0,0.02,0.04,0.06,0.08)              ; letter="(f)" }
if(file == "roughness_GMTED" )    {  des="Roughness"; max=600 ; min=get(file)@data@min ; at=pretty( min  : max ) ; labels=pretty( min  : max )                        ; letter="(g)" }
if(file == "slope_GMTED" )        {  des="Slope"; max=get(file)@data@max ; min=get(file)@data@min ; at=pretty( min  : max ) ; labels=pretty( min  : max )             ; letter="(h)" }

if(file == "aspectcosine_GMTED" ) {  des="Aspect Cosine" ; max=1 ; min=-1 ; at=pretty( min  : max ) ; labels=pretty( min  : max ) ; letter="(i)" } 
if(file == "aspectsine_GMTED" )   {  des="Aspect Sine" ; max=1 ; min=-1  ; at=pretty( min  : max ) ; labels=pretty( min  : max ) ; letter="(j)" }
if(file == "eastness_GMTED" )     {  des="Eastness"  ; max=+0.6  ; min=-0.6   ; at=c(-0.6,-0.3,0,0.3, 0.6  ) ; labels=c(-0.6,-0.3,0,0.3, 0.6  ) ; letter="(k)" }
if(file == "northness_GMTED" )    {  des="Northness" ; max=+0.6  ; min=-0.6  ; at=c(-0.6,-0.3,0,0.3, 0.6  ) ; labels=c(-0.6,-0.3,0,0.3, 0.6  ) ; letter="(l)"  }

if(file == "pcurv_GMTED" )        {  des="Profile curvature" ; max=0.0005  ; min=-0.0005 ;    at=seq (min , max  , 0.00025) ; labels=seq (min , max , 0.00025) ; letter="(m)" }
if(file == "tcurv_GMTED" )        {  des="Tangential curvature" ;  max=0.0005  ; min=-0.0005 ;    at=seq (min , max  , 0.00025) ; labels=seq (min , max , 0.00025) ; letter="(n)" } 
if(file == "dx_GMTED" )           {  des="1st partial derivative (E-W slope)" ; max=0.8 ; min=-0.8 ;  at=seq (min , max  , 0.4) ; labels=seq (min , max , 0.4) ; ; letter="(o)" }
if(file == "dxx_GMTED" )          {  des="2nd partial derivative (E-W slope)" ; max=0.001  ; min=-0.001 ;  at=trunc ( seq (-0.001 , 0.001 , 0.0005) , prec=5) ; labels=trunc ( seq (-0.001 , 0.001 , 0.0005) , prec=5) ; letter="(p)"  }

if(file == "dy_GMTED" )   {  des="1st partial derivative (N-S slope)" ;  max=0.8  ; min=-0.8     ; at=seq (min , max  , 0.4) ; labels=seq (min , max , 0.4) ; letter="(q)" } 
if(file == "dyy_GMTED" )  {  des="2nd partial derivative (N-S slope)" ;  max=0.001  ; min=-0.001 ;  at=trunc ( seq (-0.001 , 0.001 , 0.0005) , prec=5) ; labels=trunc ( seq (-0.001 , 0.001 , 0.0005) , prec=5) ; letter="(r)" }
if(file == "geomorphic_majority_GMTED" ){  des="Geomorphic classes majority"; max=10 ; min=get(file)@data@min ; at=seq (1 , 10  , 1) ;  labels=c("flat","summit","ridge","shoulder","spur","slope","hollow","footslope","valley","depression") ; letter="(s)" }
if(file == "geomorphic_class3_GMTED" )  {  des="Geomorphic ridge percentage" ; raster=raster/100  ;   max=100 ; min=raster@data@min ; at=seq (min , max  , 25 ) ; labels=seq (min , max , 25 ) ;  letter="(t)" }

if(file == "geomorphic_count_GMTED" )   {  des="Geomorphic classes count" ; max=10 ; min=1 ; at=seq (min , max  , 2 ) ; labels=seq (min , max , 2 ) ;  letter="(u)" } 
if(file == "geomorphic_shannon_GMTED" ) {  des="Geomorphic classes shannon";  max=1.8 ; min=0 ; at=seq (min , max  , 0.4 ) ; labels=seq (min , max , 0.4 )  ;  letter="(v)" }  
if(file == "geomorphic_uni_GMTED" )     {  des="Geomorphic classes uniformity" ; max=1 ; min=0 ;  at=seq (min , max  , 0.2 ) ; labels=seq (min , max , 0.2 )  ; letter="(w)" } 
if(file == "geomorphic_ent_GMTED" )     {  des="Geomorphic classes entropy"  ; max=2.8 ; min=0 ; at=seq (min , max  , 0.4 ) ; labels=seq (min , max , 0.4 )  ; letter="(x)" }  

raster[raster  > max] <-  max
raster[raster  < min] <-  min

if (( file != "geomorphic_count_GMTED" ) &&  ( file != "geomorphic_majority_GMTED" ))  { 
plot(raster   , col=cols , yaxt="n"  ,  xaxt="n" , xlab=""  , ylab="" , main=des   , legend=FALSE   , cex.main=0.65 , font.main=2 )
plot(raster, axis.args=list(  at=at , labels=labels  , line=-0.68, tck=0  )  ,    smallplot=c(0.83,0.87, 0.1,0.8), zlim=c( min, max ) , legend.only=TRUE ,  legend.width=1, legend.shrink=0.75 ,  col=cols)
text(9.88, 47.23, letter , xpd=TRUE  , cex=0.6 )
}

if ( file == "geomorphic_majority_GMTED" ) { 
plot(raster   , col=colorRampPalette(c("blue","green","yellow", "orange" , "red", "brown", "black" ))(10) , yaxt="n"  ,  xaxt="n" , xlab=""  , ylab="" , main=des   , legend=FALSE   , cex.main=0.65 , font.main=2 )
plot(raster, axis.args=list(at=at ,  labels=labels   , line=-0.68, tck=0  ), smallplot=c(0.83,0.87, 0.1,0.8), zlim=c( min, max ) , legend.only=TRUE ,  legend.width=1, legend.shrink=0.75 ,  col=colorRampPalette(c("blue","green","yellow", "orange" , "red", "brown", "black" ))(10)  )
text(9.88, 47.23, letter , xpd=TRUE  , cex=0.6 )
}


if ( file == "geomorphic_count_GMTED"  )   { 
plot(raster , col=cols , yaxp=c(46.6 , 47.2 , 4 ) , xaxp=c(8.8 , 9.8 , 4 ) ,  main=des   , legend=FALSE   , cex.main=0.65 , font.main=2   )
plot(raster , axis.args=list( at=at  , labels=labels  , line=-0.68, tck=0  ) , smallplot=c(0.83,0.87, 0.1,0.8), zlim=c( min, max ) , legend.only=TRUE ,  legend.width=1, legend.shrink=0.75 ,  col=cols , nlevel=4 )
text(9.88, 47.23, letter , xpd=TRUE , cex=0.6 )
}
} 

dev.off()



# system("evince  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/alps_all_var_plot.ps")

system("ps2pdf /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/alps_all_var_plot.ps /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/alps_all_var_plot.pdf")
system("convert -flatten -density 300 /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/alps_all_var_plot.ps /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/alps_all_var_plot.png")
system("ps2epsi /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/alps_all_var_plot.ps  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/alps_all_var_plot.eps")

