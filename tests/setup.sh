
SRCDIR=$TESTDIR/../src
ORGTOXML_HOME=${ORGTOXML_HOME:-$SRCDIR}

export PATH=$ORGTOXML_HOME:$PATH

EXAMPLES=$ORGTOXML_HOME/../examples

do_parse_unparse() {
    inorg=$1
    org-to-xml.sh $inorg > res.xml
    orgxml-to-org.sh res.xml > res.org
    diff $inorg res.org
    assertEquals "The org output should be identical to the input" "0" "$?"
}

