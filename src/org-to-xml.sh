#! /bin/sh

ORGTOXML_HOME=${ORGTOXML_HOME:-$PWD}

TMP=${TMP:-/tmp}

in=$1

tmpin=$TMP/org-to-xml-$$.org

cat $in > $tmpin

emacs --batch -l $ORGTOXML_HOME/org-to-xml.el --file $tmpin -f org-to-xml 2> /dev/null

xml=$tmpin.xml
cat $xml

rm $tmpin $xml
