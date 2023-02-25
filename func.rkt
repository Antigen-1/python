#lang racket/base
(require data-abstraction)

(define-data
  python-function
  (lib racket/function ffi/unsafe "value.rkt" "init.rkt")
  (representation
   (call-python-function
    (get-ffi-obj 'PyObject_Call
                 python-lib
                 (_fun PyObj* PyObj* PyObj* -> (r : PyObj*) -> (if r r (error "fail to call the function")))
                 (thunk (error "call-python-function:cannot be extracted"))))
   (callable? (get-ffi-obj 'PyCallable_Check
                           python-lib
                           (_fun PyObj* -> _bool)
                           (thunk (error "callable?:cannot be extracted")))))
  (abstraction))
