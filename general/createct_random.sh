#!/bin/bash
# create random color table 
# createct_random.sh input.tif  random_color.txt 

pkstat -hist -i  $1  | grep -v " 0" | awk '{ print $1  }' >  /tmp/pixel_value$$.txt 
pkcreatect -min 0 -max 255 | awk '{ print $2, $3, $4 , $5 , rand() }' | sort -k 5,5 -g | awk '{ print $1, $2, $3 , $4  }' > /tmp/random_color$$.txt 
mult=$(expr $( wc -l   /tmp/pixel_value$$.txt | awk '{print $1 }'  )  / $( wc -l /tmp/random_color$$.txt | awk '{print $1 }' ) + 1 )
for seq in $( seq 1 $mult ) ; do cat  /tmp/random_color$$.txt ; done >  /tmp/random_color_mult$$.txt 

paste -d " "  /tmp/pixel_value$$.txt  /tmp/random_color_mult$$.txt  | awk '{ if (NF==5 ) print  }' > $2
rm  /tmp/pixel_value$$.txt  /tmp/random_color_mult$$.txt 
 