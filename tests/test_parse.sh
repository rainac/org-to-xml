#! /bin/bash

TESTDIR=$(dirname $BASH_SOURCE)
. $TESTDIR/setup.sh

# test single org doc individually

test_plain() {
    rm -f $tempdir/res.xml
    org-to-xml.sh $EXAMPLES/test.org > $tempdir/res.xml
    check_well_formed $tempdir/res.xml
}

test_outfile() {
    rm -f $tempdir/res.xml
    org-to-xml.sh $EXAMPLES/test.org $tempdir/res.xml
    check_well_formed $tempdir/res.xml
}

test_outfile_option() {
    rm -f $tempdir/res.xml
    org-to-xml.sh -o $tempdir/res.xml $EXAMPLES/test.org
    check_well_formed $tempdir/res.xml
}

test_outfile_option2() {
    rm -f $tempdir/res.xml
    org-to-xml.sh $EXAMPLES/test.org -o $tempdir/res.xml
    check_well_formed $tempdir/res.xml
}

test_linked() {
    rm -f $tempdir/res.xml
    mkdir subdir
    ffn=$(readlink -f $EXAMPLES/test.org)
    ln -s $ffn subdir
    org-to-xml.sh subdir/test.org > $tempdir/res.xml
    check_well_formed $tempdir/res.xml
    rm -rf subdir
}

test_cleanup() {
    cleanup
}

. shunit2

