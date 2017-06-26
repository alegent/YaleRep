
for file in $(cat   $RAMDIR/listfile.txt   ) ; do gdalinfo $file | grep "Pixel Size" ; done | sort | head ;  for file in $(cat   $RAMDIR/listfile.txt   ) ; do gdalinfo $file | grep "Pixel Size" ; done | sort | tail
gdal_edit.py  -tr 926.625433138760627 -926.625433138788935  /nobackupp6/aguzman4/climateLayers/MOD11A2.005/MOD11A2/2005/MOD11A2.A2005249.tif

# second time for Day & Night
# correct (926.625433138760627,-926.625433138788935)

find  /nobackupp6/aguzman4/climateLayers/M{O,Y}D11A2.005/M{O,Y}D11A2/ -name  "*Day.tif" | xargs -n 1 -P 10 bash -c  $' echo $1 $(gdalinfo $1 | grep "Pixel Size")   ' _  | sort -k 5,5 | tail

/nobackupp6/aguzman4/climateLayers/MYD11A2.005/MYD11A2/2015/MYD11A2.A2015129_Day.tif Pixel Size = (926.625433138760627,-926.625433138791436)
/nobackupp6/aguzman4/climateLayers/MOD11A2.005/MOD11A2/2003/MOD11A2.A2003177_Day.tif Pixel Size = (926.625433138761878,-926.625433138790186)
/nobackupp6/aguzman4/climateLayers/MOD11A2.005/MOD11A2/2005/MOD11A2.A2005249_Day.tif Pixel Size = (926.625433138761991,-926.625433138787912)
/nobackupp6/aguzman4/climateLayers/MOD11A2.005/MOD11A2/2001/MOD11A2.A2001177_Day.tif Pixel Size = (926.625433138786889,-926.625433138782910)

find  /nobackupp6/aguzman4/climateLayers/M{O,Y}D11A2.005/M{O,Y}D11A2/ -name  "*Day.tif" | xargs -n 1 -P 10 bash -c  $' echo $1 $(gdalinfo $1 | grep "Pixel Size")   ' _  | sort -k 5,5 | tail
/nobackupp6/aguzman4/climateLayers/MYD11A2.005/MYD11A2/2015/MYD11A2.A2015145_Day.tif Pixel Size = (926.625433138760627,-926.625433138786320)

find  /nobackupp6/aguzman4/climateLayers/M{O,Y}D11A2.005/M{O,Y}D11A2/ -name  "*Nig.tif" | xargs -n 1 -P 10 bash -c  $' echo $1 $(gdalinfo $1 | grep "Pixel Size")   ' _  | sort -k 5,5 | head 
/nobackupp6/aguzman4/climateLayers/MYD11A2.005/MYD11A2/2003/MYD11A2.A2003177_Nig.tif Pixel Size = (926.625433138759945,-926.625433138788367)
/nobackupp6/aguzman4/climateLayers/MYD11A2.005/MYD11A2/2015/MYD11A2.A2015145_Nig.tif Pixel Size = (926.625433138760627,-926.625433138786320)

find  /nobackupp6/aguzman4/climateLayers/M{O,Y}D11A2.005/M{O,Y}D11A2/ -name  "*Nig.tif" | xargs -n 1 -P 10 bash -c  $' echo $1 $(gdalinfo $1 | grep "Pixel Size")   ' _  | sort -k 5,5 | tail
/nobackupp6/aguzman4/climateLayers/MYD11A2.005/MYD11A2/2015/MYD11A2.A2015129_Nig.tif Pixel Size = (926.625433138760627,-926.625433138791436)
/nobackupp6/aguzman4/climateLayers/MOD11A2.005/MOD11A2/2003/MOD11A2.A2003177_Nig.tif Pixel Size = (926.625433138761309,-926.625433138789504)
/nobackupp6/aguzman4/climateLayers/MOD11A2.005/MOD11A2/2005/MOD11A2.A2005249_Nig.tif Pixel Size = (926.625433138761991,-926.625433138787912)
/nobackupp6/aguzman4/climateLayers/MOD11A2.005/MOD11A2/2001/MOD11A2.A2001177_Nig.tif Pixel Size = (926.625433138786889,-926.625433138782910)

gdal_edit.py  -tr 926.625433138760627 -926.625433138788935 /nobackupp6/aguzman4/climateLayers/MYD11A2.005/MYD11A2/2015/MYD11A2.A2015129_Day.tif
gdal_edit.py  -tr 926.625433138760627 -926.625433138788935 /nobackupp6/aguzman4/climateLayers/MOD11A2.005/MOD11A2/2003/MOD11A2.A2003177_Day.tif
gdal_edit.py  -tr 926.625433138760627 -926.625433138788935 /nobackupp6/aguzman4/climateLayers/MOD11A2.005/MOD11A2/2005/MOD11A2.A2005249_Day.tif
gdal_edit.py  -tr 926.625433138760627 -926.625433138788935 /nobackupp6/aguzman4/climateLayers/MOD11A2.005/MOD11A2/2001/MOD11A2.A2001177_Day.tif
gdal_edit.py  -tr 926.625433138760627 -926.625433138788935 /nobackupp6/aguzman4/climateLayers/MYD11A2.005/MYD11A2/2015/MYD11A2.A2015145_Day.tif
gdal_edit.py  -tr 926.625433138760627 -926.625433138788935 /nobackupp6/aguzman4/climateLayers/MYD11A2.005/MYD11A2/2003/MYD11A2.A2003177_Nig.tif
gdal_edit.py  -tr 926.625433138760627 -926.625433138788935 /nobackupp6/aguzman4/climateLayers/MYD11A2.005/MYD11A2/2015/MYD11A2.A2015145_Nig.tif
gdal_edit.py  -tr 926.625433138760627 -926.625433138788935 /nobackupp6/aguzman4/climateLayers/MYD11A2.005/MYD11A2/2015/MYD11A2.A2015129_Nig.tif
gdal_edit.py  -tr 926.625433138760627 -926.625433138788935 /nobackupp6/aguzman4/climateLayers/MOD11A2.005/MOD11A2/2003/MOD11A2.A2003177_Nig.tif
gdal_edit.py  -tr 926.625433138760627 -926.625433138788935 /nobackupp6/aguzman4/climateLayers/MOD11A2.005/MOD11A2/2005/MOD11A2.A2005249_Nig.tif
gdal_edit.py  -tr 926.625433138760627 -926.625433138788935 /nobackupp6/aguzman4/climateLayers/MOD11A2.005/MOD11A2/2001/MOD11A2.A2001177_Nig.tif