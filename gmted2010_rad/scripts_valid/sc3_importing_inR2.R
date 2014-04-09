# setting up the list of observation file  radiation 
library(sp)
library(foreign)
library(rgl)
library(reshape)
library(latticeExtra)


path = "/mnt/data2/scratch/GMTED2010/solar_radiation/nsrdb/monthstats_txt/"
files.list = list.files(path , pattern="c*.txt")

# importing the files with 
real.sky=c(1:12)
for(file in files.list)
{
  perpos <- which(strsplit(file, "")[[1]]==".")
  a = read.table(paste(path,file,sep=""), sep=" " , header=TRUE) 
  a$CODE = gsub(" ","",substr(file, 2, perpos-1))
  real.sky = rbind (real.sky , a   )
}
rm(a)
names(real.sky)[2] ="globRobs"


# import the clear-sky radiation 
radiation.cloud = read.dbf ("/mnt/data2/scratch/GMTED2010/grassdb/shp/point_extract_rad_cloud.dbf")

d=melt(radiation.cloud,id.vars=c("X","Y","CODE"))
d$month=as.numeric(sub("[A-Z]*","",d$variable))+1
d$type=gsub("[0-9]","",d$variable)
d2=cast(d,X+Y+CODE+month~type)
names(d2)[6] ="clearModel"

radiation = merge (d2 , real.sky , by.x = c("CODE","month") , by.y = c("CODE","MO") )
radiation = subset (radiation , clearModel > 0)


# plotting  glob observed versus clear sky modelled 
plot ( radiation$clearModel , radiation$globRobs  )
# plotting  glob observed versus clear sky modelled  at month level 
xyplot (globRobs~clearModel |as.factor(month) , data=radiation )

# model real-observation vs clear model 
lm.realOBS.clearMod  = lm( radiation$globRobs ~ radiation$clearModel) 
summary(lm.realOBS.clearMod)

# da sistemare 
xyplot ( globRobs~glob |as.factor(month) , data=real.skyMod.slop1.real.skyObs )+layer(panel.abline(0,1))+layer(panel.abline(lm(y~x),col="red"))


# start to import the real-sky calculate with cloud and horzonal plane 
real.skyMod = read.dbf ("/mnt/data2/scratch/GMTED2010/grassdb/shp/p-ext-real-sky-glob-diff-beam.dbf")

d=melt(real.skyMod,id.vars=c("X","Y","CODE"))
d$month=as.numeric(sub("[a-z]*","",d$variable))+1
d$type=gsub("[0-9]","",d$variable)
d2=cast(d,X+Y+CODE+month~type)

real.skyMod.real.skyObs = merge (d2 , real.sky , by.x = c("CODE","month") , by.y = c("CODE","MO") )
real.skyMod.real.skyObs = subset (real.skyMod.real.skyObs , glob > 0)

plot ( real.skyMod.real.skyObs$glob , real.skyMod.real.skyObs$globRobs )
xyplot ( globRobs~glob |as.factor(month) , data=real.skyMod.real.skyObs )


# start to import the real-sky calculate with cloud and slope  plane - considering 1 - cloud . slop1
real.skyMod.slop1 = read.dbf ("/mnt/data2/scratch/GMTED2010/grassdb/shp/p-ext-real-sky-glob-slop1.dbf")

d=melt(real.skyMod.slop1,id.vars=c("X","Y","CODE"))
d$month=as.numeric(sub("[a-z]*","",d$variable))+1
d$type=gsub("[0-9]","",d$variable)
d2=cast(d,X+Y+CODE+month~type)

real.skyMod.slop1.real.skyObs = merge (d2 , real.sky , by.x = c("CODE","month") , by.y = c("CODE","MO") )
real.skyMod.slop1.real.skyObs = subset (real.skyMod.slop1.real.skyObs , glob > 0)

# points ( real.skyMod.slop1.real.skyObs$glob , real.skyMod.slop1.real.skyObs$globRobs , col='red' )
plot ( real.skyMod.slop1.real.skyObs$glob , real.skyMod.slop1.real.skyObs$globRobs , col='red' )
lm.realOBS.real.skyMod.slop1 = lm ( real.skyMod.slop1.real.skyObs$glob ~ real.skyMod.slop1.real.skyObs$globRobs )
xyplot ( globRobs~glob |as.factor(month) , data=real.skyMod.slop1.real.skyObs )+layer(panel.abline(0,1))+layer(panel.abline(lm(y~x),col="red"))


# start to import the real-sky calculate with cloud and horzonal plane - considering 1 - cloud . horiz1
real.skyMod.horiz1 = read.dbf ("/mnt/data2/scratch/GMTED2010/grassdb/shp/p-ext-real-sky-glob-horiz1.dbf")

d=melt(real.skyMod.horiz1,id.vars=c("X","Y","CODE"))
d$month=as.numeric(sub("[a-z]*","",d$variable))+1
d$type=gsub("[0-9]","",d$variable)
d2=cast(d,X+Y+CODE+month~type)

real.skyMod.horiz1.real.skyObs = merge (d2 , real.sky , by.x = c("CODE","month") , by.y = c("CODE","MO") )
real.skyMod.horiz1.real.skyObs = subset (real.skyMod.horiz1.real.skyObs , glob > 0)

plot ( real.skyMod.horiz1.real.skyObs$glob , real.skyMod.horiz1.real.skyObs$globRobs )
lm.realOBS.real.skyMod.horiz1 = lm ( real.skyMod.horiz1.real.skyObs$glob ~ real.skyMod.horiz1.real.skyObs$globRobs )

xyplot ( globRobs~glob |as.factor(month) , data=real.skyMod.horiz1.real.skyObs )

# aerosol 

# start to import the real-sky calculate with cloud and horzonal plane - considering 1 - cloud . horiz1
real.skyMod.horiz1.aeros = read.dbf ("/mnt/data2/scratch/GMTED2010/grassdb/shp/p-ext-real-sky-glob-horiz1-aeros.dbf")

d=melt(real.skyMod.horiz1.aeros,id.vars=c("X","Y","CODE"))
d$month=as.numeric(sub("[a-z]*","",d$variable))+1
d$type=gsub("[0-9]","",d$variable)
d2=cast(d,X+Y+CODE+month~type)

real.skyMod.horiz1.aeros.real.skyObs = merge (d2 , real.sky , by.x = c("CODE","month") , by.y = c("CODE","MO") )
real.skyMod.horiz1.aeros.real.skyObs = subset (real.skyMod.horiz1.aeros.real.skyObs , glob > 0)



# merge cloud and horzonal plane - considering 1 - cloud . horiz1   and with cloud and slope  plane - considering 1 - cloud . slop1

real.skyMod.horiz1.slop1.real.skyObs = merge ( real.skyMod.slop1.real.skyObs ,  real.skyMod.horiz1.real.skyObs , by.x = c("CODE","month") , by.y = c("CODE","month") )

names(real.skyMod.horiz1.slop1.real.skyObs)[5] = "glob.slop1"
names(real.skyMod.horiz1.slop1.real.skyObs)[6] = "globRobs"
names(real.skyMod.horiz1.slop1.real.skyObs)[9] = "glob.horiz1"

real.skyMod.horiz1.slop1.real.skyObs$globRobs.y = NULL
real.skyMod.horiz1.slop1.real.skyObs$X.y = NULL
real.skyMod.horiz1.slop1.real.skyObs$Y.x = NULL

real.skyMod.horiz1.slop1.real.skyObs = merge ( real.skyMod.horiz1.slop1.real.skyObs , radiation , by.x = c("CODE","month") , by.y = c("CODE","month") )

real.skyMod.horiz1.slop1.real.skyObs$X.y = NULL
real.skyMod.horiz1.slop1.real.skyObs$Y.x = NULL
real.skyMod.horiz1.slop1.real.skyObs$globRobs.y = NULL
real.skyMod.horiz1.slop1.real.skyObs$X.x = NULL

real.skyMod.horiz1.aeros.slop1.real.skyObs = merge ( real.skyMod.horiz1.slop1.real.skyObs , real.skyMod.horiz1.aeros.real.skyObs , by.x = c("CODE","month") , by.y = c("CODE","month") )

real.skyMod.horiz1.aeros.slop1.real.skyObs$X.y = NULL
real.skyMod.horiz1.aeros.slop1.real.skyObs$Y.x = NULL
real.skyMod.horiz1.aeros.slop1.real.skyObs$globRobs.x = NULL
real.skyMod.horiz1.aeros.slop1.real.skyObs$X.x = NULL


xyplot (clearModel~globRobs.x | as.factor(month), data=real.skyMod.horiz1.slop1.real.skyObs , xlab="Observations", ylab="Model Prediction - Linke + Albedo" , xlab.top="Global Solar Radiation")+layer(panel.abline(0,1))+layer(panel.abline(lm(y~x),col="red"))
xyplot (glob.horiz1~globRobs.x | as.factor(month), data=real.skyMod.horiz1.slop1.real.skyObs, xlab="Observations", ylab="Model Prediction - Linke + Albedo + Cloud", xlab.top="Global Solar Radiation")+layer(panel.abline(0,1))+layer(panel.abline(lm(y~x),col="red"))
xyplot (glob~globRobs| as.factor(month), data=real.skyMod.horiz1.aeros.slop1.real.skyObs, xlab="Observations", ylab="Model Prediction - Linke + Albedo + Cloud", xlab.top="Global Solar Radiation")+layer(panel.abline(0,1))+layer(panel.abline(lm(y~x),col="red"))






