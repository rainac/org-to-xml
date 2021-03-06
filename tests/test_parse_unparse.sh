#! /bin/bash

TESTDIR=$(dirname $BASH_SOURCE)
. $TESTDIR/setup.sh

# test single org doc individually
test_indiv() {
    do_parse_unparse $EXAMPLES/test.org
}


test_gen_all() {
    # header
    cat > $TESTDIR/test_parse_unparse_all.gsh <<EOF
#! /bin/bash

TESTDIR=$(dirname $BASH_SOURCE)
. $TESTDIR/setup.sh

EOF

    # tests
    k=1
    exlist="$EXAMPLES/*.org"
    if ls $EXAMPLES/private/*.org &> /dev/null; then
        exlist="$EXAMPLES/private/*.org $exlist"
    fi
    for torg in $exlist; do
        relname=${torg##$EXAMPLES/}

    cat >> $TESTDIR/test_parse_unparse_all.gsh <<EOF

test_file_$k() {
    echo testing input file: $relname
    do_parse_unparse \$EXAMPLES/$relname
}
EOF
    k=$(( $k + 1 ))
    done

    # failing tests
    k=1
    for torg in $EXAMPLES/fail/*.org; do
    cat >> $TESTDIR/test_parse_unparse_all.gsh <<EOF

test_file_fail_$k() {
    echo testing input file: $(basename $torg)
    do_parse_unparse \$EXAMPLES/fail/$(basename $torg) fail
}
EOF
    k=$(( $k + 1 ))
    done

    # footer
    cleanup=cleanup
    cat >> $TESTDIR/test_parse_unparse_all.gsh <<EOF

test_$cleanup() {
    cleanup
}

. shunit2

EOF

    chmod a+x $TESTDIR/test_parse_unparse_all.gsh

}

test_run_all() {
    $TESTDIR/test_parse_unparse_all.gsh
    assertEquals "The sub test suite should pass OK" "0" "$?"
}

test_cleanup() {
    cleanup
    rm $TESTDIR/test_parse_unparse_all.gsh
}

. shunit2
