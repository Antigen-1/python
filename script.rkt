#lang racket/base
(require data-abstraction)

(define-data
  python-execution
  (lib ffi/unsafe racket/function (only-in "init.rkt" python-lib) (only-in "value.rkt" PyObj*) (only-in "stdio.rkt" FILE*))
  (representation
   (istolated-expression-symbol (get-ffi-obj 'Py_eval_input
                                             python-lib
                                             _int
                                             (thunk (error "isolated-expression-symbol:cannot be extracted"))))
   (statement-sequence-symbol (get-ffi-obj 'Py_file_input
                                           python-lib
                                           _int
                                           (thunk (error "statement-sequence-symbol:cannot be extracted"))))
   (single-statement-symbol (get-ffi-obj 'Py_single_input
                                         python-lib
                                         _int
                                         (thunk (error "single-statement-symbol:cannot be extracted"))))
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
