#! /bin/bash

TESTDIR=$(dirname $BASH_SOURCE)
. $TESTDIR/setup.sh

test_relevel() {
    inorg=$EXAMPLES/sections-and-paras.org
    reforg=$EXAMPLES/sections-and-paras+1.org
    org-to-xml.sh $inorg > $tempdir/res.xml
    assertEquals "The script should exit successfully" "0" "$?"
    orgxml-to-org.sh -m 2 $tempdir/res.xml > $tempdir/res.org
    assertEquals "The script should exit successfully" "0" "$?"
    diff $tempdir/res.org $reforg
    assertEquals "The org with incremented levels should be equal to the reference" "0" "$?"
}

test_cleanup() {
    cleanup
}

. shunit2
