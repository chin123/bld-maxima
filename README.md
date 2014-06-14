BLD-MAXIMA calls Maxima to evaluate Maxima or Maxima lisp-level expressions.
It includes translation of Lisp math expressions to Maxima for algebraic simplification.
Lisp forms that aren't in the translation table are identified and treated as symbols in Maxima.
Depends on KMRCL for COMMAND-OUTPUT to run Maxima & get output.
Depends on CL-PPCRE for translating Lisp -> Maxima -> Lisp.

Usage:
CL-USER> (asdf:load-system 'bld-maxima)
CL-USER> (bld-maxima:simp '(+ (aref a 2) (aref a 2)))
(* 2 (AREF A 2))

Socket routines
===============
Allow running a single Maxima process and sending it commands or lisp math code to simplify over a network socket.
Depends on USOCKET.
Should run faster than non-socket version.
Requires MAXIMA-START to run a socket connected Maxima session, and MAXIMA-SHUTDOWN once finished sending computations.

Usage:
CL-USER> (bld-maxima:maxima-start)
(((%I1) (%O1) FALSE)
 ((%I2) (%O2) "/usr/share/maxima/5.20.1/share/linearalgebra/linearalgebra.mac"))
CL-USER> (bld-maxima:simp-socket '(+ (aref a 2) (aref a 2)))
(* 2 (AREF A 2))
16
CL-USER> (bld-maxima:jacobi-socket #2a((1 2)(2 1)))
#(-1.0d0 3.0d0)
#2A((0.7071067811865476d0 0.7071067811865475d0)
    (-0.7071067811865475d0 0.7071067811865476d0))
CL-USER> (bld-maxima:maxima-shutdown)
T

Alternatively, you can run these routines inside the WITH-MAXIMA macro:

CL-USER> (with-maxima
	   (simp-socket '(+ a a)))
(* 2 A)
CL-USER> 

simp-exprs
==========

The 'simp-exprs function takes a series of math expressions as
arguments and simplifies all of them with one call to Maxima instead
of several.

Delay
=====

Wrapping the 'delay' macro around a 'simp or 'simp-socket expression
prevents evaluation so it can be deferred until later, which can speed
computations in certain circumstances because of the overhead incurred
by 'simp and 'simp-socket.