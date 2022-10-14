#!/bin/bash

sudo apt update
sudo apt install -y build-essential \
	parallel \
	zlib1g-dev

git clone https://github.com/gsneha26/macos_setup.git

sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/11.4.1/local_installers/cuda-repo-ubuntu2004-11-4-local_11.4.1-470.57.02-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2004-11-4-local_11.4.1-470.57.02-1_amd64.deb
sudo apt-key add /var/cuda-repo-ubuntu2004-11-4-local/7fa2af80.pub
sudo apt-get update
sudo apt-get -y install cuda

wget https://cdn.oxfordnanoportal.com/software/analysis/ont-guppy_6.1.5_linux64.tar.gz
tar -xvf ont-guppy_6.1.5_linux64.tar.gz
cp -r ont-guppy /opt/ont-guppy
cp ont-guppy/bin/* /usr/bin/
cp ont-guppy/lib/* /usr/lib/
cp -r ont-guppy/data /usr/
rm -rf ont-guppy*

git clone https://github.com/lh3/minimap2
cd minimap2 && make
cd .. && rm -rf minimap2
