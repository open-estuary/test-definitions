#!/bin/bash

set -x

cd ../../utils
. ./sys_info.sh
. ./sh-test-lib
cd -

go version
if [ $? -ne 0 ];then
	print_info 1 golang-install
else
	yum install go
	print_info $? golang-install
fi

case "${distro}" in
	centos|fedora)
		sudo wget -O /etc/yum.repos.d/estuary.repo https://raw.githubusercontent.com/open-estuary/distro-repo/master/estuaryftp.repo
		sudo chmod +r /etc/yum.repos.d/estuary.repo
		sudo rpm --import ftp://repoftp:repopushez7411@117.78.41.188/releases/ESTUARY-GPG-KEY
		yum clean dbcache
		print_info $? setup-estuary-repository
		
		pkgs="go-bindata"
		install_deps "${pkgs}"
		print_info $? install-go-bindata
	;;
	*)
		error_msg "Unsupported distribution!"
esac

go-bindata -version
print_info $? go-bindata-version

#set a go project dir
dir="my-project"
mkdir $dir
cd $dir
#src --source code
#bin --execute
#vender --Third party Library
#pkg --Static library
mkdir src
mkdir bin
mkdir vender
mkdir pkg
print_info $? set-specific-dir

export GOPATH=`pwd`
print_info $? set-GOPATH

mkdir -p src/view
cat > src/view/index.html <<EOF
Hello, Welcome to go web programming...
EOF

go-bindata -o=./asset/asset.go -pkg=asset view/...
print_info $? go-bindata-run

ls src/asset/asset.go
print_info $? generate-binary-go

mkdir -p src/main
cat > src/main/main.go <<EOF
package main
import (
    //"net/http"
	    "asset"
)

func main() {
    dirs := []string{"view"}
	for _, dir := range dirs {
		if err := asset.RestoreAssets("./", dir); err != nil {
		    break
		}
	}

}
EOF

go build main
print_info $? build-release-go

./main
diff view/html/index.html src/view/html/index.html
print_info $? release-file

cd ..
rm -rf $dir

yum remove -y go-bindata
print_info $? remove-go-bindata








