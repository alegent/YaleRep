# source ("/home/fas/sbsc/ga254/scripts/gmted2010_res_x10/sc41_plotVariableGMTED4errorarea_levelplot.R.sh" ) 

rm(list = ls())

AREA = "fin"

require(raster)
require(rgdal)
require(rasterVis)
require(gridExtra)

GMTED="/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/"

# e=extent( 71.75 , 79.999999999999999 , 58.1666666666666666666 , 65.6666666666666666666   )

e=extent(  70.8333333333333333  , 85  , 57.3333333333333333 , 63.75   )



for ( file in c("tpi","tri","vrm","roughness","slope","aspectcosine","aspectsine","eastness","northness" ,"elevation","dx","dxx","dy","dyy","pcurv","tcurv")) {
 	raster  <- raster(paste0(GMTED,"/",AREA,"/",file,"_5KMmd_GMTEDmd.tif")) 
        raster[raster == -9999 ] <- NA
        raster = crop (raster , e)
#       raster = aggregate(raster, fact=3, fun=mean)
   	assign(paste0(file,"_GMTED") , raster  )
 }

elevation_psd_GMTED = raster("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/fin/elevation_5KMpsd_GMTEDsd.tif")
elevation_psd_GMTED = crop (elevation_psd_GMTED , e)
# elevation_psd_GMTED  = aggregate(elevation_psd_GMTED, fact=3, fun=mean)
elevation_sd_GMTED  = raster("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/GMTED/fin/elevation_5KMsd_GMTEDmd.tif")
elevation_sd_GMTED  = crop (elevation_sd_GMTED , e)
# elevation_sd_GMTED  = aggregate(elevation_sd_GMTED , fact=3, fun=mean)

for ( file in c("geom_5KMcount", "geom_5KMent","geom_5KMmaj","geom_5KMsha","geom_5KMuni","geomridge_5KMperc"  )) {

	raster  <- raster(paste0(GMTED,"/",AREA,"/",file,"_GMTEDmd.tif")) 
        raster = crop (raster , e)
#       raster = aggregate(raster, fact=3, fun=mean)
	assign(paste0(file,"_GMTED") , raster  )
}

rm(raster, GMTED , file  , AREA )

aspectcosine_GMTED = get(paste0("aspectcosine_GMTED"))
aspectsine_GMTED   = get(paste0("aspectsine_GMTED"))

stack = stack(elevation_GMTED,elevation_sd_GMTED,elevation_psd_GMTED,tpi_GMTED,tri_GMTED,vrm_GMTED,roughness_GMTED,slope_GMTED,aspectcosine_GMTED,aspectsine_GMTED,eastness_GMTED,northness_GMTED,pcurv_GMTED,tcurv_GMTED,dx_GMTED,dxx_GMTED,dy_GMTED,dyy_GMTED,geom_5KMmaj_GMTED,geomridge_5KMperc_GMTED,geom_5KMcount_GMTED,geom_5KMsha_GMTED,geom_5KMuni_GMTED,geom_5KMent_GMTED)

n=100
colR=colorRampPalette(c("blue","green","yellow", "orange" , "red", "brown", "black" ))
cols=colR(n)

options(scipen=10)
trunc <- function(x, ..., prec = 0) base::trunc(x * 10^prec, ...) / 10^prec

postscript(paste0("/lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/fin_all_var_plot.ps") ,  paper="special" ,  horizo=F , width=6, height=7.5   )
par (oma=c(2,2,2,1) , mar=c(0.4,0.5,1,2) , cex.lab=0.5 , cex=0.6 , cex.axis=0.4  ,   mfrow=c(6,4) ,  xpd=NA    )

for ( file in c("elevation_GMTED","elevation_sd_GMTED","elevation_psd_GMTED","tpi_GMTED","tri_GMTED","vrm_GMTED","roughness_GMTED","slope_GMTED","aspectcosine_GMTED","aspectsine_GMTED","eastness_GMTED","northness_GMTED","pcurv_GMTED","tcurv_GMTED","dx_GMTED","dxx_GMTED","dy_GMTED","dyy_GMTED","geom_5KMmaj_GMTED","geomridge_5KMperc_GMTED","geom_5KMcount_GMTED","geom_5KMsha_GMTED","geom_5KMuni_GMTED","geom_5KMent_GMTED") )  { 

raster=get(file)

if(file == "elevation_GMTED" )    {  des="Elevation Median" ; max=get(file)@data@max ; min=get(file)@data@min ; at=pretty( min  : max ) ; labels=pretty( min  : max ) ; letter="(a)" }
if(file == "elevation_sd_GMTED" ) {  des="Elevation St. Dev." ; max=15  ; min=0 ; at=pretty( min  : max ) ; labels=pretty( min  : max )                              ; letter="(b)" }
if(file == "elevation_psd_GMTED") {  des="Elevation Pooled St. Dev."; max=3 ; min=0 ; at=pretty( min  : max ) ; labels=pretty( min  : max )                         ; letter="(c)" }
if(file == "tpi_GMTED" )          {  des="Topographic Position Index" ; max=0.4 ; min=-0.4 ; at=pretty( min  : max ) ; labels=pretty( min  : max )                      ; letter="(d)" }

if(file == "tri_GMTED" )          {  des="Terrain Roughness Index"; max=8 ; min=get(file)@data@min ; at=pretty( min  : max ) ; labels=pretty( min  : max )          ; letter="(e)" }
if(file == "vrm_GMTED" )          {  des="Vector Ruggedness Measure" ; max=0.0002 ; min=0 ;  at=c(0,0.00005,0.00001,0,0.00015,0.0002) ; labels=at          ; letter="(f)" }
if(file == "roughness_GMTED" )    {  des="Roughness"; max=30 ; min=get(file)@data@min ; at=pretty( min  : max ) ; labels=pretty( min  : max )        ; letter="(g)" }
if(file == "slope_GMTED" )        {  des="Slope"; max=3 ; min=get(file)@data@min ; at=pretty( min  : max ) ; labels=pretty( min  : max )             ; letter="(h)" }

if(file == "aspectcosine_GMTED" ) {  des="Aspect Cosine" ; max=0.8 ; min=-0.8 ; at=pretty( min  : max ) ; labels=pretty( min  : max ) ; letter="(i)" } 
if(file == "aspectsine_GMTED" )   {  des="Aspect Sine" ; max=0.8 ; min=-0.8  ; at=pretty( min  : max ) ; labels=pretty( min  : max ) ; letter="(j)" }
if(file == "eastness_GMTED" )     {  des="Eastness"  ; max=+0.15  ; min=-0.15   ; at=c(-0.15,-0.07,0,0.07, 0.15 ) ; labels=c(-0.3,-0.15,0,0.15, 0.3  ) ; letter="(k)" }
if(file == "northness_GMTED" )    {  des="Northness" ; max=+0.15  ; min=-0.15   ; at=c(-0.15,-0.07,0,0.07, 0.15 ) ; labels=c(-0.3,-0.15,0,0.15, 0.3  ) ; letter="(l)"  }

if(file == "pcurv_GMTED" )        {  des="Profile curvature"     ; max=0.00001  ; min=-0.00001 ; at=c(-0.00001,-0.000005,0,0.000005, 0.00001 )  ; labels=at   ; letter="(m)" }
if(file == "tcurv_GMTED" )        {  des="Tangential curvature" ;  max=0.00001  ; min=-0.00001 ; at=c(-0.00001,-0.000005,0,0.000005, 0.00001 )  ; labels=at   ; letter="(n)" } 
if(file == "dx_GMTED" )           {  des="1st partial derivative (E-W slope)" ; max=0.004 ; min=-0.004 ;  at=seq (min , max  , 0.002) ; labels=at  ;  letter="(o)" }
if(file == "dxx_GMTED" )          {  des="2nd partial derivative (E-W slope)" ; max=0.00001  ; min=-0.00001 ; at=trunc ( seq (min , max , 0.000005) , prec=6) ; labels=at ; letter="(p)"  }

if(file == "dy_GMTED" )           {  des="1st partial derivative (N-S slope)" ;  max=0.004  ; min=-0.004 ; at=seq (min , max  , 0.002) ; labels=at ; letter="(q)" } 
if(file == "dyy_GMTED" )          {  des="2nd partial derivative (N-S slope)" ;  max=0.00001  ; min=-0.00001 ;  at=trunc ( seq (min , max , 0.000005) , prec=6) ; labels=at ; letter="(r)" }
if(file == "geom_5KMmaj_GMTED" ){  des="Geomorphic classes majority"; max=10 ; min=get(file)@data@min ; at=seq (1 , 10  , 1) ;  labels=c("flat","summit","ridge","shoulder","spur","slope","hollow","footslope","valley","depression") ; letter="(s)" }
if(file == "geomridge_5KMperc_GMTED" )  {  des="Geomorphic ridge percentage" ; raster=raster/100  ;   max=50 ; min=raster@data@min ; at=seq (min , max  , 10 ) ; labels=seq (min , max , 10 ) ;  letter="(t)" }

if(file == "geom_5KMcount_GMTED" )   {  des="Geomorphic classes count" ; max=10 ; min=1 ; at=seq (min , max  , 2 ) ; labels=seq (min , max , 2 ) ;  letter="(u)" } 
if(file == "geom_5KMsha_GMTED" ) {  des="Geomorphic classes shannon";  max=1.8 ; min=0 ; at=seq (min , max  , 0.4 ) ; labels=seq (min , max , 0.4 )  ;  letter="(v)" }  
if(file == "geom_5KMuni_GMTED" )     {  des="Geomorphic classes uniformity" ; max=1 ; min=0 ;  at=seq (min , max  , 0.2 ) ; labels=seq (min , max , 0.2 )  ; letter="(w)" } 
if(file == "geom_5KMent_GMTED" )     {  des="Geomorphic classes entropy"  ; max=2.8 ; min=0 ; at=seq (min , max  , 0.4 ) ; labels=seq (min , max , 0.4 )  ; letter="(x)" }  

raster[raster  > max] <-  max
raster[raster  < min] <-  min

if (( file != "geom_5KMcount_GMTED" ) &&  ( file != "geom_5KMmaj_GMTED" ))  { 
plot(raster   , col=cols , yaxt="n"  ,  xaxt="n" , xlab=""  , ylab="" , main=des   , legend=FALSE   , cex.main=0.65 , font.main=2 )
plot(raster, axis.args=list(  at=at , labels=labels  , line=-0.68, tck=0  )  ,    smallplot=c(0.83,0.87, 0.1,0.8), zlim=c( min, max ) , legend.only=TRUE ,  legend.width=1, legend.shrink=0.75 ,  col=cols)
text(86, 64., letter , xpd=TRUE , cex=0.6 )
}

if ( file == "geom_5KMmaj_GMTED" ) { 
plot(raster   , col=colorRampPalette(c("blue","green","yellow", "orange" , "red", "brown", "black" ))(10) , yaxt="n"  ,  xaxt="n" , xlab=""  , ylab="" , main=des   , legend=FALSE   , cex.main=0.65 , font.main=2 )
plot(raster, axis.args=list(at=at ,  labels=labels   , line=-0.68, tck=0  ), smallplot=c(0.83,0.87, 0.1,0.8), zlim=c( min, max ) , legend.only=TRUE ,  legend.width=1, legend.shrink=0.75 ,  col=colorRampPalette(c("blue","green","yellow", "orange" , "red", "brown", "black" ))(10)  )
text(86, 64., letter , xpd=TRUE , cex=0.6 )
}

e=extent(  70.8333333333333333  , 85  , 57.3333333333333333 , 63.75   )

if ( file == "geom_5KMcount_GMTED"  )   { 
plot(raster, col=cols, yaxp=c(57.4, 63.7, 4) , xaxp=c(70.9 , 85.0 , 4) ,  main=des , legend=FALSE   , cex.main=0.65 , font.main=2   )
plot(raster, axis.args=list( at=at  , labels=labels  , line=-0.68, tck=0  ) , smallplot=c(0.83,0.87, 0.1,0.8), zlim=c( min, max ) , legend.only=TRUE ,  legend.width=1, legend.shrink=0.75 ,  col=cols , nlevel=4 )
text(86, 64., letter , xpd=TRUE , cex=0.6 )
}
} 

dev.off()

print("finish plotting")

# system("evince  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/fin_all_var_plot.ps")

system("ps2pdf /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/fin_all_var_plot.ps /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/fin_all_var_plot.pdf")
system("convert -flatten -density 300 /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/fin_all_var_plot.ps /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/fin_all_var_plot.png")
system("ps2epsi /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/fin_all_var_plot.ps  /lustre/scratch/client/fas/sbsc/ga254/dataproces/GMTED2010/correlation/SRTM_GMTED/figure/fin_all_var_plot.eps")

