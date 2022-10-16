#!/bin/bash

sudo apt update
sudo apt install -y build-essential \
        parallel \
        zlib1g-dev

git clone https://github.com/gsneha26/macos_setup.git
cd macos_setup
cp -r vim ~/.vim
cp vimrc ~/.vimrc
cd ..

wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/11.6.2/local_installers/cuda-repo-ubuntu2004-11-6-local_11.6.2-510.47.03-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2004-11-6-local_11.6.2-510.47.03-1_amd64.deb
sudo apt-key add /var/cuda-repo-ubuntu2004-11-6-local/7fa2af80.pub
sudo apt-get update
sudo apt-get -y install cuda
rm cuda-repo-ubuntu2004-11-6-local_11.6.2-510.47.03-1_amd64.deb

wget https://cdn.oxfordnanoportal.com/software/analysis/ont-guppy_6.1.5_linux64.tar.gz
tar -xvf ont-guppy_6.1.5_linux64.tar.gz
cp -r ont-guppy /opt/ont-guppy
cp ont-guppy/bin/* /usr/bin/
cp ont-guppy/lib/* /usr/lib/
cp -r ont-guppy/data /usr/
rm -rf ont-guppy*

git clone https://github.com/lh3/minimap2
cd minimap2 && git checkout v2.24
make -j
cp minimap2 /usr/bin/
cd .. && rm -rf minimap2

sudo apt-get -y install libncurses-dev \
     libbz2-dev \
     liblzma-dev

wget https://github.com/samtools/samtools/releases/download/1.16.1/samtools-1.16.1.tar.bz2
tar -xvf samtools-1.16.1.tar.bz2
cd samtools-1.16.1
./configure --prefix=/usr/
make -j
sudo make install
