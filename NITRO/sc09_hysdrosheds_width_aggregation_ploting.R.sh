#!/bin/bash
#SBATCH -p scavenge
#SBATCH -n 1 -c 1  -N 1  
#SBATCH -t 24:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=email
#SBATCH -o /gpfs/scratch60/fas/sbsc/ga254/grace0/stdout/sc08_hysdrosheds_width_aggregation_ploting.R.%J.out
#SBATCH -e /gpfs/scratch60/fas/sbsc/ga254/grace0/stderr/sc08_hysdrosheds_width_aggregation_ploting.R.%J.err
#SBATCH --job-name=sc08_hysdrosheds_width_aggregation_ploting.R.sh

# sbatch /gpfs/home/fas/sbsc/ga254/scripts/NITRO/sc09_hysdrosheds_width_aggregation_ploting.R.sh


export OUTDIR=/gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NITRO/GRWL
export RAM=/dev/shm

cd /gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NITRO/GRWL
# awk ' {   if ($2 > 1 ) print   }'  $OUTDIR/FLO1K_qav_grwl_1km_clean.txt > $OUTDIR/FLO1K_qav_grwl_1km_clean_moreW1.txt


module load Apps/R/3.3.2-generic


R --vanilla --no-readline   -q  <<'EOF'

library(ggplot2)
table=read.table("/gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NITRO/GRWL/FLO1K_qav_grwl_1km_clean_moreW1.txt")
colnames(table)[1] = "Q"  # FLO1K
colnames(table)[2] = "W"  # GRWL 


# lm = lm(  log(table$W) ~  log(table$Q)) 

# y <- log(table$W) 
# x <- log(table$Q)

y = log( table$W[table$Q > 1 ])
x = log( table$Q[table$Q > 1 ])

lm = lm(  x ~ y) 
df <- data.frame(x = x, y = y,
  d = densCols(x, y, colramp = colorRampPalette(rev(rainbow(10, end = 4/6)))))
p <- ggplot( data = df   , aes(x = x , y = y)) + 
    geom_point(aes(x, y, col = d), size = 0.4) +
    scale_color_identity() +
    geom_smooth(method = "lm", se = FALSE , color = "black"  )  +
    labs(x = "log(Q-FLO1K) (m3/s)")  + 
    labs(y = "log(W-GRWL) (m)")  + 
    theme_bw()
# print(p)
ggsave("/gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NITRO/GRWL/Q_FLO1K_vs_W_GRWL.png")


w_pete1  <- (0.510 * x ) + 1.86
w_pete2  <- (0.423 * x ) + 2.56
# a-coefficient = 8.5 and b-exponent = 0.47 
w_georg  <- (0.47  * x ) + log(8.5)

# GRWL vs W calculate with Pete1 formula 
x <- w_pete1 
lm = lm(  x ~ y) 
df <- data.frame(x = x, y = y,
  d = densCols(x, y, colramp = colorRampPalette(rev(rainbow(10, end = 4/6)))))
p <- ggplot( data = df   , aes(x = x , y = y)) + 
    geom_point(aes(x, y, col = d), size = 0.4) +
    scale_color_identity() +
    geom_smooth(method = "lm", se = FALSE , color = "black"  )  +
    labs(x = "log(W-Pete1) (M)")  + 
    labs(y = "log(W) (m)")  + 
    theme_bw()
# print(p)

ggsave("/gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NITRO/GRWL/W_GRWL_W_Pete1.png")

# GRWL vs W calculate with Pete2 formula 

x <- w_pete2 
lm = lm(  x ~ y) 
df <- data.frame(x = x, y = y,
  d = densCols(x, y, colramp = colorRampPalette(rev(rainbow(10, end = 4/6)))))
p <- ggplot( data = df   , aes(x = x , y = y)) + 
    geom_point(aes(x, y, col = d), size = 0.4) +
    scale_color_identity() +
    geom_smooth(method = "lm", se = FALSE , color = "black"  )  +
    labs(x = "log(W-Pete2) (m)")  + 
    labs(y = "log(W) (m)")  + 
    theme_bw()
# print(p)

ggsave("/gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NITRO/GRWL/W_GRWL_W_Pete2.png")

# GRWL vs W calculate with George formula 

x <- w_georg 
lm = lm(  x ~ y) 
df <- data.frame(x = x, y = y,
  d = densCols(x, y, colramp = colorRampPalette(rev(rainbow(10, end = 4/6)))))
p <- ggplot( data = df   , aes(x = x , y = y)) + 
    geom_point(aes(x, y, col = d), size = 0.4) +
    scale_color_identity() +
    geom_smooth(method = "lm", se = FALSE , color = "black"  )  +
    labs(x = "log(W-George) (m)")  + 
    labs(y = "log(W) (m)")  + 
    theme_bw()
# print(p)

ggsave("/gpfs/loomis/project/fas/sbsc/ga254/grace0.grace.hpc.yale.internal/dataproces/NITRO/GRWL/W_GRWL_W_Georg.png")

EOF

exit 
