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

(defun write-text (txt out map)
  (princ txt (lambda (charcode)
               (princ
                (or (cdr (assoc charcode map))
                    (char-to-string charcode))
                out))))

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
      (write-text o out xml-content-encode-map)

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
                  (write-text value out xml-attribute-encode-map)
                  (princ "\"" out))))

        (princ (concat ">" xml-nl) out)

        (loop for x on attributes by 'cddr do
              (let ((key (first x))
                    (value (cadr x)))

                (when (and value (not (listp value)) (equal (substring (symbol-name key) 1) "value"))
                  (princ "<value>" out)
                  (write-text value out xml-content-encode-map)
                  (princ "</value>" out))

                (when (and (listp value)
                           (> (length value) 0)
                           (not (equal (substring (symbol-name key) 1) "parent"))
                           (not (equal (substring (symbol-name key) 1) "structure")))
                  (princ (concat "<" (substring (symbol-name key) 1) ">") out)
                  (if (org-item-p value)
                      (write-xml value out parents-and-self (+ 1 depth))
                    (write-list value out parents-and-self depth))
                  (princ (concat "</" (substring (symbol-name key) 1) ">") out))
                ))

        (loop for e in (cddr o)  do
              (write-xml e out parents-and-self (+ 1 depth)))

        (dotimes (x depth) (princ xml-indent out))
        (princ "</" out)
        (princ (car o) out)
        (princ (concat ">" xml-nl) out)))))

(defun plistp (value)
  (when (and (listp value) (symbolp (car value)) (equal (substring (symbol-name (car value)) 0 1) ":"))
    't))

(defun org-item-p (value)
  (when (and (listp value) (plistp (cadr value)))
    't))

(defun write-list (value out parents depth)
  (loop for i in value do
        (princ "<item>" out)
        (if (listp i)
            (if (org-item-p i)
                (write-xml i out parents depth)
              (let ()
                (princ "<list>" out)
                (write-list i out parents depth)
                (princ "</list>" out))
              )
          (write-text i out xml-content-encode-map))
        (princ "</item>" out)))

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

(defun org-to-xml-file (xmlfile)
  "Export the current org file to XML and open in new buffer.
Does nothing if the current buffer is not in org-mode."
  (interactive)
  (when (eq major-mode 'org-mode)
    (org-file-to-xml
     buffer-file-name xmlfile)))
