

echo FORMAT

umount  /media/selv/* 
/sbin/mkfs.ntfs  -Q -v -F -L "" /dev/sdb & 
/sbin/mkfs.ntfs  -Q -v -F -L "" /dev/sdc &
/sbin/mkfs.ntfs  -Q -v -F -L "" /dev/sdd 

sleep 15

echo DIR

rm -rf /media/selv/*
mkdir /media/selv/USBsdb
mkdir /media/selv/USBsdc
# mkdir /media/selv/USBsdd

echo MOUNT

sudo mount -t ntfs-3g /dev/sdb /media/selv/USBsdb 
sudo mount -t ntfs-3g /dev/sdc /media/selv/USBsdc 
sudo mount -t ntfs-3g /dev/sdd /media/selv/USBsdd

sleep 10

echo COPY

cp -r /home/selv/LVM  /media/selv/USBsdb & 
cp -r /home/selv/LVM  /media/selv/USBsdc 
# cp -r /home/selv/LVM  /media/selv/USBsdd 


