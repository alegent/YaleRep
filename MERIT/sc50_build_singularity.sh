# sudo singularity build UbuntuWB.simg  build_singularity.sh
Bootstrap: docker
From: ubuntu:16.04


%post
    apt-get -y update
    apt-get -y upgrade
    apt-get -y install software-properties-common build-essential cmake
    apt-get -y install wget
    

    echo start to install WB
    
wget http://www.uoguelph.ca/~hydrogeo/WhiteboxTools/WhiteboxTools_linux_amd64.tar.xz
tar xvf WhiteboxTools_linux_amd64.tar.xz

ls WBT


