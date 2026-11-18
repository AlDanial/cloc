;;;; Test fixture for the CLIPS language
;;;; https://www.clipsrules.net/

;;; Templates

(deftemplate person
   "A person with a name and an age"
   (slot name (type STRING))
   (slot age (type INTEGER) (default 0)))  ; inline comment

   ; indented full-line comment

(deffacts initial-people
   (person (name "Ada; Lovelace") (age 36))   ; semicolon inside a string
   (person (name "Alan") (age 41)))

;; Rules

(defrule greet-adult
   (person (name ?n) (age ?a&:(>= ?a 18)))
   =>
   (printout t "Hello, " ?n "; welcome!" crlf))

(deffunction banner ()
   "Print a banner spanning
over several; lines (this semicolon is inside the string)
to the end"
   (printout t "=====" crlf))

(defglobal ?*count* = 0) ;; trailing double-semicolon comment
