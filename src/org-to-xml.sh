#! /bin/bash

res=0
SRCDIR=$(dirname $(readlink -f $BASH_SOURCE))
ORGTOXML_HOME=${ORGTOXML_HOME:-$SRCDIR}

if [[ "$ORGTOXML_DEBUG" = "1" ]]; then
    debug=1
    set -x
fi

TMP=${TMP:-/tmp}
tempdir=${TMP}/org-to-xml-$$

optstr="Difho:rt:vV"
TEMP=$(getopt -n org-to-xml -a -o $optstr -l list-includes,full,help,output:,resolve,tmp-dir:,verbose,version -- "$@")

if [ $? != 0 ] ; then echo "Error parsing options..." >&2 ; exit 1 ; fi

eval set -- "$TEMP"

while true ; do
    OPT=$1
    OPTARG=$2
#    echo "parse option OPT=$OPT OPTARG=$OPTARG"
    case $OPT in
        (-D)
            debug=1
            debopt=-D
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
        (-r|--resolve)
            resolve=1
            shift
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

if [[ "$list_includes" = "1" ]]; then
    $SRCDIR/org-to-xml.sh $in $tempdir/out.xml
    res=$?
    if [[ -z "$out" ]]; then
        out=-
    fi
    if [ "$res" = "0" ]; then
        touch "$out"
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

if [[ "$full" = "1" || "$resolve" = "1" ]]; then
    $SRCDIR/org-to-xml.sh -i -o $tempdir/include-list.txt $in
    res=$?
    exec 5<$tempdir/include-list.txt
    while read -r -u 5 incfile word2 word3; do
        if [[ "$(basename $incfile .org).org" = "$incfile" ]]; then
            incorg=$(readlink -f $(dirname $in))/$incfile
            incxml="$tempdir/$(basename $incfile .org).xml"
            env_MINLEVEL=$O2XMINLEVEL
            if [[ "$word2" = ":minlevel" ]]; then
                export O2XMINLEVEL=$(( $word3 - 1 ))
            fi
            $SRCDIR/org-to-xml.sh $debopt -f -o $incxml $incorg
            if [[ "$word2" = ":minlevel" ]]; then
                min_level=$word3
                if [[ -n "$env_MINLEVEL" ]]; then
                    min_level=$(( $min_level - $env_MINLEVEL ))
                fi
                $SRCDIR/orgxml-to-org.sh $debopt -m $min_level -o $tempdir/$incfile.$word3 $incxml
            fi
        fi
    done
    if [[ "$full" = "1" ]]; then
        awk -f $SRCDIR/insert-includes.awk -v O2XBASEDIR="$(dirname $in)" -v O2XTMPDIR="$tempdir" $in > $tempdir/$(basename $in)
        $SRCDIR/org-to-xml.sh -o $emout $tempdir/$(basename $in)
    else
        awk -f $SRCDIR/insert-includes.awk -v O2XBASEDIR="$(dirname $in)" -v O2XTMPDIR="$tempdir" $in > $emout
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
