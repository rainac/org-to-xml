;; 
;; from
;; "emacs-org mode and html publishing: how to change structure of generated HTML"
;; http://stackoverflow.com/questions/14323854/emacs-org-mode-and-html-publishing-how-to-change-structure-of-generated-html
;; Answer by harpo
;; 

;; Changes:
;; assoc is obsolete, aget does not exist anymore
;; replaced aget -> assq

;; no indentation, newlines printed, so that texts can be reproduced faithfully

(require 'org-element)
(require 'cl)
;; (require 'cl-lib)
;; (require 'assoc)

(defvar xml-content-encode-map
  '((?& . "&amp;")
    (?< . "&lt;")
    (?> . "&gt;")))

(defvar xml-attribute-encode-map
  (cons '(?\" . "&quot;") xml-content-encode-map))

;; indentation disabled
(defvar xml-indent "")
;; newlines disabled
(defvar xml-nl "")

(defun write-xml (o out parents depth)
  "Writes O as XML to OUT, assuming that lists have a plist as
their second element (for representing attributes).  Skips basic
cycles (elements pointing to ancestor), and compound values for
attributes."
  (if (not (listp o))
      ;; TODO: this expression is repeated below
      (princ o (lambda (charcode)
                 (princ 
                  (or (cdr (assoc charcode xml-content-encode-map))
                      (char-to-string charcode))
                  out)))

    (unless (member o parents)
      (let ((parents-and-self (cons o parents))
            (attributes (cadr o)))

        (dotimes (x depth) (princ xml-indent out))
        (princ "<" out)
        (princ (car o) out)

        (loop for x on attributes by 'cddr do
              (let ((key (first x))
                    (value (cadr x)))

                (when (and value (not (listp value)) (not (equal (substring (symbol-name key) 1) "value")))
                  (princ " " out)
                  (princ (substring (symbol-name key) 1) out)
                  (princ "=\"" out)
                  (princ value  (lambda (charcode)
                                  (princ 
                                   (or (cdr (assoc charcode xml-attribute-encode-map))
                                       (char-to-string charcode))
                                   out)))
                  (princ "\"" out))))

        (princ (concat ">" xml-nl) out)

        (loop for x on attributes by 'cddr do
              (let ((key (first x))
                    (value (cadr x)))

                (when (and value (equal (substring (symbol-name key) 1) "value"))
                  (princ "<value>" out)
                  (princ value  (lambda (charcode)
                                  (princ
                                   (or (cdr (assoc charcode xml-attribute-encode-map))
                                       (char-to-string charcode))
                                   out)))
                  (princ "</value>" out))

                (when (and (listp value) (> (length value) 0) (not (equal (substring (symbol-name key) 1) "parent")))
                  (princ "<" out)
                  (princ (substring (symbol-name key) 1) out)
                  (princ ">" out)
                  (loop for i in value do
                        (princ "<item>" out)
                        (princ i (lambda (charcode)
                                        (princ
                                         (or (cdr (assoc charcode xml-attribute-encode-map))
                                             (char-to-string charcode))
                                         out)))
                        (princ "</item>" out)
                        )
                  (princ "</" out)
                  (princ (substring (symbol-name key) 1) out)
                  (princ ">" out))
                ))

        (loop for e in (cddr o)  do
              (write-xml e out parents-and-self (+ 1 depth)))

        (dotimes (x depth) (princ xml-indent out))
        (princ "</" out)
        (princ (car o) out)
        (princ (concat ">" xml-nl) out)))))

(defun org-file-to-xml (orgfile xmlfile)
  "Serialize ORGFILE file as XML to XMLFILE."
  (save-excursion
    (find-file orgfile)
    (let ((org-doc (org-element-parse-buffer)))
      (with-temp-file xmlfile
        (let ((buffer (current-buffer)))
          (princ "<?xml version='1.0'?>\n" buffer)
          (write-xml org-doc buffer () 0)
          (nxml-mode)))))
;;  (find-file xmlfile)
;;  (nxml-mode)
  )

(defun org-to-xml ()
  "Export the current org file to XML and open in new buffer.
Does nothing if the current buffer is not in org-mode."
  (interactive)
  (when (eq major-mode 'org-mode)
    (org-file-to-xml
     (buffer-file-name)
     (concat (buffer-file-name) ".xml"))))
