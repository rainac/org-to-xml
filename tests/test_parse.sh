#! /bin/bash

TESTDIR=$(dirname $BASH_SOURCE)
. $TESTDIR/setup.sh

# test single org doc individually

test_plain() {
    rm -f res.xml
    org-to-xml.sh $EXAMPLES/test.org > res.xml
    check_well_formed res.xml
}

test_outfile() {
    rm -f res.xml
    org-to-xml.sh $EXAMPLES/test.org res.xml
    check_well_formed res.xml
}

test_outfile_option() {
    rm -f res.xml
    org-to-xml.sh -o res.xml $EXAMPLES/test.org
    check_well_formed res.xml
}

test_outfile_option2() {
    rm -f res.xml
    org-to-xml.sh $EXAMPLES/test.org -o res.xml
    check_well_formed res.xml
}

test_linked() {
    rm -f res.xml
    mkdir subdir
    ffn=$(readlink -f $EXAMPLES/test.org)
    ln -s $ffn subdir
    org-to-xml.sh subdir/test.org > res.xml
    check_well_formed res.xml
    rm -rf subdir
}

. shunit2

