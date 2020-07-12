#!/usr/bin/env bash

if ! which dashing >/dev/null 2>&1
then
    echo "missing command 'dashing', please install it (https://github.com/technosophos/dashing) first."
    exit 1
fi

jsons=(SysReg.json A64_ISA.json AArch32_ISA.json)
rm -rf docs
mkdir -p docs
for j in "${jsons[@]}"; do
    if [ ! -f $j ]
    then
        echo "the JSON configuration file($j) of 'dashing build' command is missing, skip!"
        continue
    fi

    t=$(ls src | grep ${j%%.json} | sort -r | head -1)
    if [ -z "$t" ]
    then
        echo "then source file(src/${j%%.json}*) for 'dashing build' command is missing, skip!!"
        continue
    fi

    rm -rf build
    mkdir -p build
    cd build || { echo "mkdir error!!!"; exit 2; }
    tar -zxf ../src/$t
    s=$(find . -type d -iname xhtml | sort -r | head -1)
    if [ -z "$s" ]
    then
        echo "can't find directory 'xhtml'!!!"
        exit 3
    fi
    echo $j $s
    dashing build --config "../$j" --source "$s"
    mv *.docset ../docs/
    cd ..
    rm -rf build
done