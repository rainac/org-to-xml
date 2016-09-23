#! /bin/bash

SRCDIR=$(dirname $BASH_SOURCE)
ORGTOXML_HOME=${ORGTOXML_HOME:-$SRCDIR}

if [[ "$ORGTOXML_DEBUG" = "1" ]]; then
    set -x
fi

TMP=${TMP:-/tmp}
tempdir=${TMP}/org-to-xml-$$
mkdir $tempdir

in=$1
out=$2

if [[ -z "$out" ]]; then
    emout=$tempdir/out.xml
else
    emout=$(readlink -f $out)
fi

emacs --batch -l $ORGTOXML_HOME/org-to-xml.el --file $in --eval "(org-to-xml-file \"$emout\")" 2> $tempdir/err
res=$?

if [[ "$res" != "0" ]]; then
    echo "XML export failed:" >&2
    cat $tempdir/err >&2
fi

if [[ -z "$out" ]]; then
    cat $emout
fi

rm -rf $tempdir
