#!/bin/bash

sudo apt update
sudo apt install -y build-essential \
	parallel \
	zlib1g-dev

git clone https://github.com/gsneha26/macos_setup.git
git clone https://github.com/gsneha26/urWGS.git

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
