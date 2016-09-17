#! /bin/bash

SRCDIR=$(dirname $BASH_SOURCE)
ORGTOXML_HOME=${ORGTOXML_HOME:-$SRCDIR}

in=$1

emacs --batch -l $ORGTOXML_HOME/org-to-xml.el --file $in -f org-to-xml 2> /dev/null

xml=$in.xml
cat $xml
rm $xml
