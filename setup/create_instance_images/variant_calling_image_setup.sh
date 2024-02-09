#!/bin/bash                                                                                                                                                                                                                                                                                                                                                                                                                                 

CURR_DIR=$(pwd)
sudo apt -y update
sudo apt install -y build-essential \
        parallel \
        zlib1g-dev \
        libncurses-dev \
        libbz2-dev \
        liblzma-dev \
        python3-pip \
        docker.io

git clone https://github.com/gsneha26/macos_setup.git
cd macos_setup
cp -r vim ~/.vim
cp vimrc ~/.vimrc
cd $CURR_DIR
rm -rf macos_setup

wget https://github.com/samtools/samtools/releases/download/1.19.2/samtools-1.19.2.tar.bz2
tar -xvf samtools-1.19.2.tar.bz2
cd samtools-1.19.2
./configure --prefix=/usr/
make -j
sudo make install
cd $CURR_DIR
rm samtools-1.19.2.tar.bz2
rm -rf samtools-1.19.2

BIN_VERSION="1.6.0"
sudo docker pull google/deepvariant:"${BIN_VERSION}"

sudo pip install sniffles

cd $CURR_DIR
mkdir -p miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm -rf miniconda3/miniconda.sh
miniconda3/bin/conda init bash
source ~/.bashrc

cd $CURR_DIR
git clone https://github.com/fritzsedlazeck/Spectre.git
cd Spectre
conda create -n spectre python=3.8.5 pip -y
conda activate spectre
pip install -r requirements.txt
conda deactivate
