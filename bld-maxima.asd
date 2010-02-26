(defpackage :bld.maxima.system
  (:use :asdf :cl))
(in-package :bld.maxima.system)
(defsystem :bld-maxima
    :name "bld-maxima"
    :author "Benjamin L. Diedrich <ben@solarsails.info>"
    :version "0.0.1"
    :maintainer "Benjamin L. Diedrich <ben@solarsails.info>"
    :license "LLGPL"
    :description "Send commands to Maxima program, including simplification of Lisp math expressions."
    :components 
    ((:file "maxima"))
    :depends-on ("kmrcl" "split-sequence" "cl-ppcre"))
