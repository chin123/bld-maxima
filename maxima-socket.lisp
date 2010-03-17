;; Maxima interface
;; Converts CL math expressions to Maxima equivalent and evaluates them in Maxima's Lisp level to simplify them
;; Results are returned and extracted from the Maxima output

(in-package :bld-maxima)

(defvar *maxima-port* 4011)
(defvar *maxima-socket-options* "-q")
(defvar *maxima-socket-init-forms* ; list of initial Maxima forms to execute on start
  '("display2d : false" ; Show results without 2D rendering
    "load(\"linearalgebra\")")) ; load linearalgebra library for jacobi routine
(defvar *maxima-host* "localhost")
(defvar *maxima-socket-passive* nil)
(defvar *maxima-socket* nil)
(defvar *maxima-pid* nil)

(defun maxima-listen ()
  "Setup a server socket to listen to Maxima process"
  (setq *maxima-socket-passive* (socket-listen *maxima-host* *maxima-port*)))

(defun maxima-run ()
  (run-shell-command "~a ~a -s ~a &~%" *maxima-binary* *maxima-socket-options* *maxima-port*))

(defun maxima-accept ()
  "Accept socket connection to Maxima process"
  (setq *maxima-socket* (socket-accept *maxima-socket-passive*))
  (setq *maxima-pid* (read-line (socket-stream *maxima-socket*))))

(defun maxima-read (&key (timeout 1) (num 1))
  "Read next output of Maxima"
  (loop repeat num
     collect
       (read (socket-stream 
	      (wait-for-input *maxima-socket* :timeout timeout)))))

(defun maxima-send (string &key (num 3))
  "Send Maxima form as string"
  (let ((stream (socket-stream *maxima-socket*)))
    (format stream "~a;~%" string)
    (force-output stream))
  (maxima-read :num num))

(defun maxima-send-lisp (string &key (num 2))
  "Send Maxima lisp form as string"
  (maxima-send (format nil ":lisp ~a" string) :num num))

(defun maxima-quit ()
  "Send quit() command to maxima"
  (maxima-send "quit()" :num 0))

(defun maxima-shutdown ()
  "Shutdown maxima"
  (maxima-quit)
  (socket-close *maxima-socket*))

(defun maxima-start ()
  "Start a Maxima process and send initial forms"
  (unless *maxima-socket-passive* (maxima-listen))
  (maxima-run)
  (maxima-accept)
  (mapcar #'maxima-send *maxima-socket-init-forms*))

(defun simp-socket (lisp-expr)
  "Simplify a lisp math expression using a Maxima socket connection"
  (let* ((maxima-string (lisp-to-maxima-string (format nil "~a" lisp-expr)))
	 (lisp-funs (match-lisp-funs maxima-string))
	 (ren-funs (loop repeat (length lisp-funs) 
		      collect (format nil "~a" (gensym))))
	 (*read-default-float-format* 'double-float))
    (read-from-string
     (maxima-to-lisp-string
      (re-rename-lisp-funs
       (format
	nil "~a"
	(second
	 (maxima-send-lisp
	  (format
	   nil "(simplify '~a)"
	   (rename-lisp-funs maxima-string lisp-funs ren-funs)))))
       lisp-funs
       ren-funs)))))

(defun jacobi-socket (a)
  "Calculate eigenvalues & eigenvectors of a 2D real symmetric array using Maxima's EIGENS_BY_JACOBI"
  (let* ((*read-default-float-format* 'double-float)
	 (result 
	  (second
	   (maxima-send-lisp
	    (format nil "(mfuncall '\\$eigens_by_jacobi ~a)"
		    (array-to-matrix a))))))
    (values
     (mlist-to-array (second result)) ; eigenvalues
     (matrix-to-array (third result))))) ; eigenvectors
