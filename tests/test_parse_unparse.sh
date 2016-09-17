#! /bin/bash

TESTDIR=$(dirname $BASH_SOURCE)
. $TESTDIR/setup.sh

# test single org doc individually
test_indiv() {
    do_parse_unparse $EXAMPLES/test.org
}


test_gen_all() {
    # header
    cat > $TESTDIR/test_parse_unparse_all.sh <<EOF
#! /bin/bash

TESTDIR=$(dirname $BASH_SOURCE)
. $TESTDIR/setup.sh

EOF

    # tests
    k=1
    for torg in $EXAMPLES/*.org; do
    cat >> $TESTDIR/test_parse_unparse_all.sh <<EOF

test_file_$k() {
    echo testing input file: $(basename $torg)
    do_parse_unparse \$EXAMPLES/$(basename $torg)
}
EOF
    k=$(( $k + 1 ))
    done

    # footer
    cat >> $TESTDIR/test_parse_unparse_all.sh <<EOF

. shunit2

EOF

    chmod a+x $TESTDIR/test_parse_unparse_all.sh

}

test_run_all() {
    $TESTDIR/test_parse_unparse_all.sh
}

. shunit2


