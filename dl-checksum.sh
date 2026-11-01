#!/usr/bin/env sh
set -e
MIRROR=https://github.com/sigstore/cosign/releases/download
APP=cosign
ID=keyless@projectsigstore.iam.gserviceaccount.com
ISSUER=https://accounts.google.com

TMPD=$(mktemp -d)
trap 'rm -rf "$TMPD"' EXIT

fetch()
{
    curl -fsSL --proto '=https' --tlsv1.2 -o "$2" "$1"
}

dl_ver()
{
    local ver=$1
    local base=$MIRROR/v$ver
    local d=$TMPD/$ver
    local sums=$d/${APP}_checksums.txt
    mkdir -p "$d"
    fetch "$base/${APP}_checksums.txt" "$sums"
    # releases before 3.0 ship a detached sig + cert, later ones a sigstore bundle
    if fetch "$base/${APP}_checksums.txt.sigstore.json" "$d/bundle.json" 2>/dev/null
    then
        cosign verify-blob --bundle "$d/bundle.json" \
            --certificate-identity "$ID" --certificate-oidc-issuer "$ISSUER" "$sums" >&2
    else
        fetch "$base/${APP}_checksums.txt-keyless.sig" "$d/sums.sig"
        fetch "$base/${APP}_checksums.txt-keyless.pem" "$d/sums.pem"
        cosign verify-blob --certificate "$d/sums.pem" --signature "$d/sums.sig" \
            --certificate-identity "$ID" --certificate-oidc-issuer "$ISSUER" "$sums" >&2
    fi

    printf "  '%s':\n" "$ver"
    for p in darwin-amd64 darwin-arm64 linux-amd64 linux-arm linux-arm64 linux-ppc64le linux-riscv64 linux-s390x windows-amd64
    do
        local file=${APP}-${p}
        case $p in windows-*) file=$file.exe;; esac
        local sum
        sum=$(grep -F -- "  $file" "$sums" | awk -v f="$file" '$2 == f {print $1}')
        if [ -z "$sum" ]
        then
            # riscv64 only exists for some releases
            if [ "$p" = linux-riscv64 ]; then continue; fi
            echo "no checksum for $file in $ver" >&2
            exit 1
        fi
        if ! printf '%s' "$sum" | grep -Eq '^[0-9a-f]{64}$'
        then
            echo "bad checksum for $file in $ver: $sum" >&2
            exit 1
        fi
        printf "    # %s/%s\n" "$base" "$file"
        printf "    %s: sha256:%s\n" "$p" "$sum"
    done
}

if [ $# -eq 0 ]; then set -- 3.1.4; fi
for v in "$@"; do dl_ver "$v"; done
