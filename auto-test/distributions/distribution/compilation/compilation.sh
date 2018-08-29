#!/bin/bash
# Author: mahongxin <hongxin_228@163.com>
set -x
cd ../../../../utils
. ./sys_info.sh
. ./sh-test-lib
cd -

#Test user id
if [ `whoami` != 'root' ]; then
    echo " You must be the superuser to run this script" >&2
    exit 1
fi

#install gcc g++
case $distro in
    "ubuntu"|"debian")
        pkgs="gcc g++ openjdk-8-jdk"
        install_deps "${pkgs}"
        print_info $? install-package
        ;;
    "centos"|"fedora"|"opensuse")
	pkgs="gcc gcc-c++ java-1.8.0-openjdk"
	install_deps "${pkgs}"
        print_info $? install-package
        ;;
esac

#make a file based on C program
cat <<EOF >> ./main.c
#include <stdio.h>
int main()
{
    printf("hello world\n");
    return 0;
}
EOF

#compile the source file
gcc main.c -o test1.o
print_info $? compilation-Cfile

#run the compiled file 
./test1.o
print_info $? run-Cfile

#make a file based on C++ program
cat <<EOF >> ./main.cpp
#include <iostream>
using namespace std;
int main()
{
	cout << "hello world!" << endl;
        return 0;
}
EOF

#compile the source file
g++ main.cpp -o test2.o
print_info $? compilation-C++file

#run the compiled file
./test2.o
print_info $? run-C++file

#make a file based on JAVA program
cat <<EOF >> ./test3.java
public class test3 {
    public static void main(String[] args) {
        System.out.println("Hello World");
    }
}
EOF

#compile the source file
javac test3.java
print_info $? compilation-JAVAfile

#run the compiled file
java test3
print_info $? run-JAVAfile

case $distro in
    "ubuntu"|"debian")
        pkgs="gcc g++"
        remove_deps "${pkgs}"
        print_info $? remove-package
        ;;
    "centos"|"fedora"|"opensuse")
        pkgs="gcc gcc-c++"
        remove_deps "${pkgs}"
        print_info $? remove-package
        ;;
esac

rm -f main.c test1.o main.cpp test2.o test3.java test3.class

