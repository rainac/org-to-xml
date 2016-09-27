#! /bin/bash

SRCDIR=$(dirname $BASH_SOURCE)
ORGTOXML_HOME=${ORGTOXML_HOME:-$SRCDIR}

TMP=${TMP:-/tmp}
tempdir=${TMP}/orgxml-to-org-$$

min_level=0

optstr="Dhm:o:t:vV"
TEMP=$(getopt -n org-to-xml -a -o $optstr -l min-level:,help,output:,tmp-dir:,verbose,version -- "$@")

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
        (-m|--min-level)
            min_level=$OPTARG
            shift 2
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

mkdir $tempdir

cleanup() {
    if [[ -z "$debug" ]]; then
        rm -rf $tempdir
    fi
}

if [[ -z "$out" ]]; then
    xpout=$tempdir/out.org
else
    xpout=$(readlink -f $out)
fi

xpflags=""
if [[ "$min_level" != "0" ]]; then
    xpflags="$xpflags --stringparam min-level $min_level"
fi

xsltproc -o $xpout $xpflags $ORGTOXML_HOME/orgxml-to-org.xsl $in

if [[ -z "$out" ]]; then
    cat $xpout
fi

cleanup

exit $res
