org-to-xml
==========

Export Org-mode document structure to XML and back, reproducing the
org file identically


Usage
-----

Within Emacs: Load `src/org-to-xml.el` and then use the function
`org-to-xml`, which will save the current Org-mode buffer to
*filename*`.xml`, where *filename* is the name of the buffer.

As a standalone command: You can also invoke Emacs in batch mode from
a shell script, for example see `src/org-to-xml.sh`.

The XML output format can be converted back to the org syntax
with an XSL stylesheet. The original org file is reproduced
identically. There also is a shell script for that inverse
transformation, see `src/orgxml-to-org.sh`.

Taken together, the two scripts provide a facility to perform
arbitrary transformations of org files via the XML representation,
using XSL, for example.


History
-------

*org-to-xml* is originally, and still for the most part, based on a
piece of Emacs Lisp code posted as an answer by user harpo to the
question on stackoverflow.com
[emacs-org mode and html publishing: how to change structure of generated HTML](http://stackoverflow.com/questions/14323854/emacs-org-mode-and-html-publishing-how-to-change-structure-of-generated-html)

Initially I just changed two or three things which didn't work in my
emacs (any more) and added some wrapper scripts. Over time I have also
expanded the functionality somewhat. In particular, I added an XSL
stylesheet to reproduce the original org file. This required
however to slightly modify the XML output format.

Also, some tests were added to check that Org-mode markup features are
recognized, represented in XML and that they can be reproduced
identically.
