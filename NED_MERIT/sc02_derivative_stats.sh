#SBATCH -p scavenge 
#SBATCH -n 1 -c 1 -N 1 
#SBATCH -t 24:00:00
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc02_derivative_stats.sh.%J.out
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc02_derivative_stats.sh.%J.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email
#SBATCH -J sc02_derivative_stats.sh 

# sbatch /gpfs/home/fas/sbsc/ga254/scripts/NED_MERIT/sc02_derivative_stats.sh 

# module load Apps/R/3.0.3  
module load Apps/R/3.1.1-generic

cd /project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NED_MERIT


# cat <(echo input_tif slope dx dxx dxy dy dyy pcurv roughness tcurv tpi tri vrm spi tci convergence | xargs -n 1 -P 1 bash -c $' echo $1 $(  pkinfo   -nodata -9999 -stats -i $1/tiles/n40w100.tif )  ' _  ; echo  sin cos Nw Ew  | xargs -n 1 -P 1 bash -c $' echo $1 $( pkinfo   -nodata -9999 -stats -i aspect/tiles/n40w100_$1.tif ) ' _  ) >  txt/n40w100_der_stats.txt 


# cat <(echo input_tif slope dx dxx dxy dy dyy pcurv roughness tcurv tpi tri vrm spi tci convergence | xargs -n 1 -P 1 bash -c $' echo $1 $(  pkinfo   -nodata -9999 -stats -i $1/tiles/n45w120.tif )  ' _  ; echo  sin cos Nw Ew  | xargs -n 1 -P 1 bash -c $' echo $1 $( pkinfo   -nodata -9999 -stats -i aspect/tiles/n45w120_$1.tif ) ' _  ) >  txt/n45w120_der_stats.txt 


R  --vanilla --no-readline   -q  <<EOF
library(ggplot2) 

n40w100 = read.table("txt/n40w100_der_stats.txt")
n45w120 = read.table("txt/n45w120_der_stats.txt")

n40w100.ord =   n40w100[1,]
n40w100.ord = rbind (   n40w100.ord ,   n40w100[9,] ) 
n40w100.ord = rbind (   n40w100.ord ,   n40w100[12,] )
n40w100.ord = rbind (   n40w100.ord ,   n40w100[11,] )
n40w100.ord = rbind (   n40w100.ord ,   n40w100[13,] )
n40w100.ord = rbind (   n40w100.ord ,   n40w100[15,] )
n40w100.ord = rbind (   n40w100.ord ,   n40w100[14,] )
n40w100.ord = rbind (   n40w100.ord ,   n40w100[18,] )
n40w100.ord = rbind (   n40w100.ord ,   n40w100[17,] )
n40w100.ord = rbind (   n40w100.ord ,   n40w100[2,] )
n40w100.ord = rbind (   n40w100.ord ,   n40w100[20,] )
n40w100.ord = rbind (   n40w100.ord ,   n40w100[19,] )
n40w100.ord = rbind (   n40w100.ord ,   n40w100[8,] )
n40w100.ord = rbind (   n40w100.ord ,   n40w100[10,] )
n40w100.ord = rbind (   n40w100.ord ,   n40w100[3,] )
n40w100.ord = rbind (   n40w100.ord ,   n40w100[6,] )
n40w100.ord = rbind (   n40w100.ord ,   n40w100[4,] )
n40w100.ord = rbind (   n40w100.ord ,   n40w100[7,] )
n40w100.ord = rbind (   n40w100.ord ,   n40w100[5,] )
n40w100.ord = rbind (   n40w100.ord ,   n40w100[16,] )


n45w120.ord =   n45w120[1,]
n45w120.ord = rbind (   n45w120.ord ,   n45w120[9,] ) 
n45w120.ord = rbind (   n45w120.ord ,   n45w120[12,] )
n45w120.ord = rbind (   n45w120.ord ,   n45w120[11,] )
n45w120.ord = rbind (   n45w120.ord ,   n45w120[13,] )
n45w120.ord = rbind (   n45w120.ord ,   n45w120[15,] )
n45w120.ord = rbind (   n45w120.ord ,   n45w120[14,] )
n45w120.ord = rbind (   n45w120.ord ,   n45w120[18,] )
n45w120.ord = rbind (   n45w120.ord ,   n45w120[17,] )
n45w120.ord = rbind (   n45w120.ord ,   n45w120[2,] )
n45w120.ord = rbind (   n45w120.ord ,   n45w120[20,] )
n45w120.ord = rbind (   n45w120.ord ,   n45w120[19,] )
n45w120.ord = rbind (   n45w120.ord ,   n45w120[8,] )
n45w120.ord = rbind (   n45w120.ord ,   n45w120[10,] )
n45w120.ord = rbind (   n45w120.ord ,   n45w120[3,] )
n45w120.ord = rbind (   n45w120.ord ,   n45w120[6,] )
n45w120.ord = rbind (   n45w120.ord ,   n45w120[4,] )
n45w120.ord = rbind (   n45w120.ord ,   n45w120[7,] )
n45w120.ord = rbind (   n45w120.ord ,   n45w120[5,] )
n45w120.ord = rbind (   n45w120.ord ,   n45w120[16,] )

n40w100.ord\$ID = as.numeric(seq(1,20)) 
n45w120.ord\$ID = as.numeric(seq(1,20)) 

pdf( paste ("figure/plot_derivative.pdf", sep="") , width=8, height=8 )

ggplot() +
    geom_line(data = n40w100.ord , aes(x=ID , y = V7),  color = "orange") +
    geom_line(data = n45w120.ord , aes(x=ID , y = V7),  color = "blue"  ) +
    geom_errorbar(data = n40w100.ord, aes(x=ID , ymin=V7-(V9/2), ymax=V7+(V9/2)), width=0.05 ,  color = "orange") +
    geom_errorbar(data = n45w120.ord, aes(x=ID , ymin=V7-(V9/2), ymax=V7+(V9/2)), width=0.05 ,  color = "blue")   +
    theme(plot.margin = unit(c(1,1,1,1), "cm")) +
    theme(panel.border = element_blank(),  panel.grid.minor = element_blank()) +
    theme(axis.text.x = element_text(angle=45 , hjust=1,   size=16 , color="black" ))  +
    theme(axis.text.y = element_text( size=16 , color="black"))  +
    theme(axis.title.x=element_text(size=20 , vjust=-5  )) +
    theme(axis.title.y=element_text(size=20 , vjust=2  )) +
    scale_x_discrete( limits=seq(1, 20),  breaks=seq(1,20) , labels=c("elevation","roughness","tri","tpi","vrm","tci","spi","aspectcosine","aspectsine","slope","eastness","northness","pcurv","tcurv","dx","dy","dxx","dyy","dxy","convergence")) + 
    labs(x = "Topographic variables" , y = "Derivative (degrees)")

dev.off()

EOF




exit 
   scale_x_continuous( limits=c(-3, 10) , breaks=seq(0,9) , labels=c(-5,-4,-3,-2,-1,0,1,2,3,4)  ) +
    scale_y_continuous( limits=c(22, 46) , breaks=c(25,30,35,40,45)          ) +

