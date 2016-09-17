#! /bin/bash

SRCDIR=$(dirname $BASH_SOURCE)
ORGTOXML_HOME=${ORGTOXML_HOME:-$SRCDIR}
TMP=${TMP:-/tmp}

in=$1
org=$TMP/$in.org

xsltproc -o $org $ORGTOXML_HOME/orgxml-to-org.xsl $in

cat $org
rm $org
