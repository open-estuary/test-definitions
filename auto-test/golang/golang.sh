#!/bin/bash

set -x

cd ../../utils
. ./sys_info.sh
. ./sh-test-lib
cd -

case "${distro}" in
	centos|fedora)
		pkgs="go"
		install_deps "${pkgs}"
		print_info $? install-golang
	;;
	*)
		error_msg "Unsupported distribution!"
esac

go version
print_info $? golang-version

cat > hello.go <<EOF
package main
import "fmt"
func main() {
    fmt.Println("Hello, World!")
}
EOF
go run hello.go |grep 'Hello'
print_info $? run-simple-go

cat > maximum.go <<EOF
package main

import "fmt"

func main() {
   /* define values */
    var a int = 100
	var b int = 200
	var ret int

	/* Call the function and return the maximum value */
	ret = max(a, b)

	fmt.Printf( "the maximum value : %d\n", ret  )
}

/* Returns the maximum value of two numbers */
func max(num1, num2 int) int {
   /* Defining local variables */
    var result int

	if (num1 > num2) {
	    result = num1
	} else {
	    result = num2
	}
	
	return result
}
EOF
go run maximum.go | grep 'maximum'
print_info $? run-maximum-go

cat > concurrent.go <<EOF
package main
import (
    "fmt"
    "time"
)

func test_print(a int){
    fmt.Println(a)
}

func main(){
    for i:= 0;i < 100; i ++ {
        go test_print(i)
    }
    time.Sleep(time.Second)
}
EOF
go run concurrent.go
print_info $? run-concurrent-go

cat > pipe.go <<EOF
package main
import (
    "fmt"
)

func test_pipe(){
    pipe := make(chan int,3)
    pipe <- 1
    pipe <- 2
    pipe <- 3
    fmt.Println(len(pipe))
}

func main(){
    test_pipe()
}
EOF

go run pipe.go |grep '3'
print_info $? run-pipe-go

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

mkdir -p src/hello
cp ../hello.go src/hello/hello.go
go build hello
print_info $? build-hello-go

./hello
print_info $? run-build-hello

mkdir src/http
cat > src/http/http.go <<EOF
package main
import (
    "fmt"
    "net/http"
)

func main(){
    if err := http.ListenAndServe(":12345",nil); err != nil{
        fmt.Println("start http server fail:",err)
	}
}
EOF
go build http
print_info $? build-http-go

./http &
netstat -anp | grep 12345
print_info $? http-bind-port

curl http://localhost:12345 | grep '404'
print_info $? http-server

kill -9 $(pidof http)
print_info $? kill-go-http

cd ..
rm -rf $dir

yum remove -y go
print_info $? remove-golang


