#!/bin/bash

haxe build-mig-helper.hxml          &&\
haxe build-mig-runner.hxml          &&\

# rm -rf ./build/mig-test
# mkdir ./build/mig-test

neko ./build/mig-helper/run.n $@ /acerola
