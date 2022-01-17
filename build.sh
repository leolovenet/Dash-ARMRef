#!/usr/bin/env bash

if ! which dashing >/dev/null 2>&1
then
    echo "missing command 'dashing', please install it (https://github.com/technosophos/dashing) first."
    exit 1
fi

jsons=(SysReg_xml_v8.json SysReg_xml_v9.json SysReg_xml_Morello.json ISA_A64_xml_v8.json ISA_A64_xml_v9.json A64_ISA_xml_morello.json ISA_AArch32_xml_v8.json)
pwd=$(pwd)

rm -rf docs
mkdir -p docs
for j in "${jsons[@]}"; do
    if [ ! -f "$j" ]
    then
        echo "the JSON configuration file($j) of 'dashing build' command is missing, skip!"
        continue
    fi

    t=$(ls src/*.tar.gz | grep ${j%%.json} | sort -r | head -1)
    if [ -z "$t" ]
    then
        echo "then source file(src/${j%%.json}*) for 'dashing build' command is missing, skip!!"
        continue
    fi

    rm -rf build
    mkdir -p build
    cd build || { echo "mkdir error!!!"; exit 2; }

    tar -zxf "../$t"
    s=$(find . -type d -iname xhtml | sort -r | head -1)
    if [ -z "$s" ]
    then
        echo "can't find directory 'xhtml'!!!"
        exit 3
    fi

    cp "../icon@2x.png" "$s/"
    cp "../$j" "$s/dashing.json"
    (cd "$s" && dashing build && mv *.docset "$pwd/docs")

    cd ..
    rm -rf build
done

cd "$pwd/docs" || { echo "cd '$pwd/docs' error!"; exit 2; }
pwd
for d in *.docset; do
    [[ -e "$d" ]] || break
    tar --exclude='.DS_Store' -cvzf "${d%%.docset}.tgz" "$d"
done
