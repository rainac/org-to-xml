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

test_include_resolving() {
    org-to-xml.sh -o include-full.org -r $EXAMPLES/include.org
    diff include-full.org $EXAMPLES/include-resolved.org
    assertEquals "The resolved org file output should be as expected" "0" "$?"
    rm -rf include-full.org
}

test_full() {
    org-to-xml.sh -o out-full.xml -f $EXAMPLES/include.org
    org-to-xml.sh -o out-cmp.xml $EXAMPLES/include-resolved.org
    sed -e 's/include-resolved/include/g' out-cmp.xml > out-cmp-CAT.xml
    $TESTDIR/../src/emacs-xml-indent.sh out-full.xml out-full-i.xml
    $TESTDIR/../src/emacs-xml-indent.sh out-cmp-CAT.xml out-cmp-i.xml
    diff out-full-i.xml out-cmp-i.xml
    assertEquals "The resolved XML output should be as expected" "0" "$?"
    rm -rf out-full.xml out-cmp.xml out-cmp-CAT.xml out-full-i.xml out-cmp-i.xml
}

test_include_resolving_minlevel() {
    org-to-xml.sh -o include-full.org -r $EXAMPLES/include-minlevel.org
    diff include-full.org $EXAMPLES/include-minlevel-resolved.org
    assertEquals "The resolved org file output should be as expected" "0" "$?"
    rm -rf include-full.org
}

test_full_minlevel() {
    org-to-xml.sh -o out-full.xml -f $EXAMPLES/include-minlevel.org
    org-to-xml.sh -o out-cmp.xml $EXAMPLES/include-minlevel-resolved.org
    sed -e 's/include-minlevel-resolved/include-minlevel/g' out-cmp.xml > out-cmp-CAT.xml
    $TESTDIR/../src/emacs-xml-indent.sh out-full.xml out-full-i.xml
    $TESTDIR/../src/emacs-xml-indent.sh out-cmp-CAT.xml out-cmp-i.xml
    diff out-full-i.xml out-cmp-i.xml
    assertEquals "The resolved XML output should be as expected" "0" "$?"
    rm -rf out-full.xml out-cmp.xml out-cmp-CAT.xml out-full-i.xml out-cmp-i.xml
}

. shunit2

