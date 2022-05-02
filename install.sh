#! /bin/sh

set -x

PREFIX=${1:-/usr/local}

ln -sfT $PWD/src/org-to-xml.sh $PREFIX/bin/org-to-xml.sh
