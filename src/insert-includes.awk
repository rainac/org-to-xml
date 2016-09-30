BEGIN { IGNORECASE=1; skip=0 }

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
