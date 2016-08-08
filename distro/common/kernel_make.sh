#!/bin/bash

log_file="kernel_build.log"

if [ "$1"x != ""x ]; then
    VERSION=$1
fi

current_path=$PWD
if [ ! -e bin ]; then 
    mkdir -p bin;
    let i=0
    while (( $i < 5 )); do
        wget -c http://www.open-estuary.com/EstuaryDownloads/tools/repo -O bin/repo
        if [ $? -eq 0 ]; then
            break;
        fi
        let "i++"
    done
    chmod a+x bin/repo; 
fi 

# get the newest content of git repos
export PATH=${current_path}/bin:$PATH; 
open_estuary_dir=open-estuary 
if [ ! -e $open_estuary_dir ]; then
    mkdir -p $open_estuary_dir; 
fi
if [ -e $open_estuary_dir ]; then
    cd $open_estuary_dir;
    repo abandon master
    repo forall -c git reset --hard
    if [ "$VERSION"x != ""x ]; then
        repo init -u "https://github.com/open-estuary/estuary.git" -b refs/tags/$VERSION --no-repo-verify --repo-url=git://android.git.linaro.org/tools/repo
    else
        repo init -u "https://github.com/open-estuary/estuary.git" -b master --no-repo-verify --repo-url=git://android.git.linaro.org/tools/repo
    fi      
    false; while [ $? -ne 0 ]; do repo sync; done
    repo start master --all
    if [ $? -ne 0  -o  "$(ls -l)"x != ""x ]; then
        echo "update the estaury code fail\n"
        lava-test-case download-estuary-code --result fail
        lava-test-case build-estuary-native --result fail
        exit 0
    else
        echo "update the estaury code success\n"
        lava-test-case download-estuary-code --result pass
    fi
    cd ..
fi

################ build one platform and one distro  ####################
DISTRO="ubuntu"
PLATFORM="D02"

.  ../../common/scripts/install_dmidecode.sh | tee ${log_file}
product_name=$(dmidecode -s system-product-name)
if [ "$(echo $product_name | grep -E 'D02|d02')"x != ""x ]; then
    PLATFORM="D02"
elif [ "$(echo $product_name | grep -E 'D03|d03')"x != ""x ]; then
    PLATFORM="D03"
elif [ "$(echo $product_name | grep -E 'D01|d01')"x != ""x ]; then
    PLATFORM="D01"
else
    PLATFORM="D02"
fi

pushd ${open_estuary_dir}
    ./estuary/build.sh -p $PLATFORM -d $DISTRO  | tee ${log_file}
    if [ $? -ne 0 ]; then
        echo "build the $DISTRO for $PLATFORM error"
        lava-test-case build-estuary-native --result fail
    else
        echo "build the $DISTRO for $PLATFORM pass"
        lava-test-case build-estuary-native --result pass
    fi
popd

lava-test-run-attach ${log_file}

