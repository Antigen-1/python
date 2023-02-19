#lang racket/base
(require data-abstraction)

(define-data
  python-execution
  (lib ffi/unsafe racket/function (only-in "init.rkt" python-lib) (only-in "value.rkt" PyObj*) (only-in "stdio.rkt" FILE*))
  (representation
   (run-file (get-ffi-obj 'PyRun_File
                          python-lib
                          (_fun FILE*
                                _file
                                _int
                                PyObj*
                                PyObj* 
                                -> (r : PyObj*)
                                -> (if r r (error "fail to run the file")))))
   (eval-string (get-ffi-obj 'PyRun_String
                             python-lib
                             (_fun _string
                                   _int
                                   PyObj*
                                   PyObj*
                                   -> (r : PyObj*)
                                   -> (if r r (error "fail to eval the string"))))))
  (abstraction))
