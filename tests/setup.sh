
SRCDIR=$TESTDIR/../src
ORGTOXML_HOME=${ORGTOXML_HOME:-$SRCDIR}

export PATH=$ORGTOXML_HOME:$PATH

EXAMPLES=$ORGTOXML_HOME/../examples

TMP=${TMP:-/tmp}
tempdir=$TMP/o2x-tests-$$
mkdir $tempdir

do_parse_unparse() {
    inorg=$1
    fail=$2
    org-to-xml.sh $inorg > $tempdir/res.xml
    assertEquals "The script should exit successfully" "0" "$?"
    orgxml-to-org.sh $tempdir/res.xml > $tempdir/res.org
    assertEquals "The script should exit successfully" "0" "$?"
    diff $inorg $tempdir/res.org
    res=$?
    if [[ -z "$fail" ]]; then
        assertEquals "The org output should be identical to the input" "0" "$res"
    else
        assertEquals "This test fails" "1" "$res"
    fi
}

check_well_formed() {
    inxml=$1
    xsltproc $ORGTOXML_HOME/orgxml-to-org.xsl $inxml > /dev/null
    assertEquals "The file $inxml should be well-formed XML" "0" "$?"
}

cleanup() {
    rm -rf $tempdir
}
