#! /bin/bash

res=0
SRCDIR=$(dirname $BASH_SOURCE)
ORGTOXML_HOME=${ORGTOXML_HOME:-$SRCDIR}

if [[ "$ORGTOXML_DEBUG" = "1" ]]; then
    debug=1
    set -x
fi

TMP=${TMP:-/tmp}
tempdir=${TMP}/org-to-xml-$$

optstr="Difho:t:vV"
TEMP=$(getopt -n org-to-xml -a -o $optstr -l list-includes,full,help,output:,tmp-dir:,verbose,version -- "$@")

if [ $? != 0 ] ; then echo "Error parsing options..." >&2 ; exit 1 ; fi

eval set -- "$TEMP"

while true ; do
    OPT=$1
    OPTARG=$2
#    echo "parse option OPT=$OPT OPTARG=$OPTARG"
    case $OPT in
        (-D)
            debug=1
            set -x
            shift
            ;;
        (-i|--list-includes)
            list_includes=1
            shift
            ;;
        (-f|--full)
            full=1
            shift
            ;;
        (-h|--help)
            show_help=1
            shift
            ;;
        (-v|--version)
            show_version=1
            shift
            ;;
        (-V|--verbose)
            verbose=1
            shift
            ;;
        (-o|--output)
            out=$OPTARG
            shift 2
            ;;
        (-t|--tmp-dir)
            tempdir=$OPTARG
            shift 2
            ;;
        (--)
            shift
            break
    esac
done

mkdir $tempdir

if [[ "$show_help" = "1" ]]; then
    echo "org-to-xml.sh {option} input.org output.xml"
    exit 0
fi

if [[ "$show_version" = "1" ]]; then
    echo "org-to-xml.sh version 0.1"
    exit 0
fi

in=$1
if [[ -z "$out" ]]; then
    out=$2
fi

cleanup() {
    if [[ -z "$debug" ]]; then
        rm -rf $tempdir
    fi
}

if [[ "$list_includes" = "1" ]]; then
    $SRCDIR/org-to-xml.sh $in $tempdir/out.xml
    res=$?
    if [[ -z "$out" ]]; then
        out=-
    fi
    if [ "$res" = "0" ]; then
        xsltproc -o "$out" $ORGTOXML_HOME/list-includes.xsl $tempdir/out.xml
        res=$?
    fi
    cleanup
    exit $res
fi

if [[ -z "$out" ]]; then
    emout=$tempdir/out.xml
else
    emout=$(readlink -f $out)
fi

if [[ "$full" = "1" ]]; then
    $SRCDIR/org-to-xml.sh -i -o $tempdir/include-list.txt $in
    res=$?
    if [ "$res" = "0" ]; then
        awk '{ print $1 }'  $tempdir/include-list.txt | grep -E ".*\.org$" | sort | uniq > $tempdir/include-org-file-list.txt
    fi
    for incfile in $(cat $tempdir/include-org-file-list.txt); do
        incorg=$(readlink -f $(dirname $in))/$incfile
        $SRCDIR/org-to-xml.sh -o $tempdir/$(basename $incfile .org).xml $incorg
        resk=$?
        if [ "$resk" != "0" ]; then
            echo "$0: Failed to process include file $incfile ($incorg)" >&2
            res=8
            break
        fi
        echo "Processed include file $incfile ($incorg)" >&2
    done
    if [ "$res" = "0" ]; then
        $SRCDIR/org-to-xml.sh $in $tempdir/unres.xml
        res=$?
        if [ "$res" = "0" ]; then
            echo "Processed main org file $in" >&2
            xsltproc -o $emout --stringparam tempdir "$tempdir" $ORGTOXML_HOME/resolve-includes.xsl $tempdir/unres.xml
        fi
    fi
    if [[ -z "$out" ]]; then
        cat $emout
    fi
    cleanup
    exit $res
fi

emacs --batch -l $ORGTOXML_HOME/org-to-xml.el --file $in --eval "(org-to-xml-file \"$emout\")" 2> $tempdir/err
res=$?

if [[ "$res" != "0" ]]; then
    echo "XML export failed:" >&2
    cat $tempdir/err >&2
    cat $emout >&2
fi

if [[ -z "$out" ]]; then
    cat $emout
fi

cleanup

exit $res
