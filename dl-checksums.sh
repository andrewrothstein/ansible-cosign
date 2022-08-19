#!/usr/bin/env sh
set -e
DIR=~/Downloads
MIRROR=https://github.com/sigstore/cosign/releases/download
APP=cosign

dl()
{
    local ver=$1
    local os=$2
    local arch=$3
    local dotexe=${4:-}
    local platform="${os}-${arch}"
    # https://github.com/sigstore/cosign/releases/download/v1.8.0/cosign-linux-amd64
    local url=$MIRROR/v$ver/${APP}-${platform}${dotexe}
    local lfile=$DIR/${APP}-${ver}-${platform}${dotexe}
    if [ ! -e $lfile ];
    then
        curl -sSLf -o $lfile $url
    fi
    printf "    # %s\n" $url
    printf "    %s: sha256:%s\n" $platform $(sha256sum $lfile | awk '{print $1}')
}

dl_ver() {
    local ver=$1
    printf "  '%s':\n" $ver
    dl $ver darwin amd64
    dl $ver darwin arm64
    dl $ver linux amd64
    dl $ver linux arm
    dl $ver linux arm64
    dl $ver linux ppc64le
    dl $ver linux s390x
    dl $ver windows amd64 .exe
}

dl_ver ${1:-1.11.0}
