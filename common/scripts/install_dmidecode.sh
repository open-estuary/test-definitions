#!/bin/bash

dmi_dir=dmiDecode
# install dmidecode
dmidecode -h 
if [ $? -ne 0 ]; then
    echo "dmidecode has not been installed, starting to install..."
    wget http://ftp.twaren.net/Unix/NonGNU//dmidecode/dmidecode-3.0.tar.xz
    [ ! -d $dmi_dir ] && mkdir $dmi_dir
    tar xf dmidecode-3.0.tar.xz -C $dmi_dir
    cd $dmi_dir
    cd dmidecode-3.0
    make 
    make install
    dmidecode -h
    if [ $? -ne 0 ]; then
        echo "dmidecode install failed"
    else
        echo "dmidecode installed success"
    fi
else
    echo "dmidecode have installed"
fi


