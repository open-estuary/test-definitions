#!/bin/bash



cd lmbench-3.0-a9
sed -i s/-O\ /-O2\ /g src/Makefile

make OS=lmbench
