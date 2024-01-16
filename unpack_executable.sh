#!/bin/bash
if [[ $# -lt 1 ]]; then
    echo "Usage: script [orcaslicer|prusaslicer|superslicer] (version)"
    exit -1
fi

if [[ $# -eq 2 ]]; then
    url=$(/slic3r/get_latest_release/${1}.sh url_ver $2)
    package_name=$(/slic3r/get_latest_release/${1}.sh name_ver $2)
elif [[ $# -eq 1 ]]; then
    url=$(/slic3r/get_latest_release/${1}.sh url)
    package_name=$(/slic3r/get_latest_release/${1}.sh name)
else
    echo "Wrong number of arguments. 1 or 2 expected. Got $#"
    exit -1
fi

echo $url
echo $package_name

curl -sSL $url -o $package_name \

if [[ $package_name == *.tar.zip ]]; then
    tar -xzf ${package_name} -C /slic3r/slic3r-dist --strip-components 1
elif [[ $package_name == *.tar.bz2 ]]; then
    tar -xjf ${package_name} -C /slic3r/slic3r-dist --strip-components 1
elif [[ $package_name == *.AppImage ]]; then
    chmod +x $package_name
    ./${package_name} --appimage-extract
    mv squashfs-root/* /slic3r/slic3r-dist/
    rm -rf squashfs-root
else
    echo "Unhandled package type."
    exit -1
fi

rm -f /slic3r/${package_name}

SLICER_EXE=$(find /slic3r/slic3r-dist/bin/ -iname "*slicer*" )

mv $SLICER_EXE /slic3r/slic3r-dist/bin/slicer
chmod +x /slic3r/slic3r-dist/bin/slicer

rm /tmp/*.json