BEGIN {
    IGNORECASE=1;
    skip=0;
    if (length(O2XTMPDIR) == 0)
        O2XTMPDIR=".";
    if (length(O2XBASEDIR) == 0)
        O2XBASEDIR="."
}

/#\+INCLUDE:/ {
    if (index($2, ".org") > 0) {
        if ($3 == ":minlevel") {
            system("cat " O2XTMPDIR "/" $2 "." $4)
        } else {
            system("cat " O2XBASEDIR "/" $2)
        }
    } else {
        print $0
    }
    skip=1
}

{
    if (!skip) { print $0 }
    skip=0
}
