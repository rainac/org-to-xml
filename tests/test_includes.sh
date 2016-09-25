#! /bin/bash

TESTDIR=$(dirname $BASH_SOURCE)
. $TESTDIR/setup.sh

test_include_lists() {
    rm -rf list.txt
    org-to-xml.sh -i $EXAMPLES/include.org > list.txt
    echo "test.org" > cmp.txt
    echo "test.sh src sh" >> cmp.txt
    echo "abc.org" >> cmp.txt
    diff list.txt cmp.txt
    assertEquals "The include list output should be as expected" "0" "$?"
    rm -rf list.txt cmp.txt
}

test_include_lists2() {
    rm -rf list.txt
    org-to-xml.sh -o list.txt -i $EXAMPLES/include.org
    echo "test.org" > cmp.txt
    echo "test.sh src sh" >> cmp.txt
    echo "abc.org" >> cmp.txt
    diff list.txt cmp.txt
    assertEquals "The include list output should be as expected" "0" "$?"
    rm -rf list.txt cmp.txt
}

. shunit2

