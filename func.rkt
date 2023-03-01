#lang racket/base
(require data-abstraction)

(define-data
  python-function
  (lib racket/function ffi/unsafe "value.rkt" "init.rkt" "err.rkt" (only-in '#%foreign ffi-call))
  (representation
   (call-python-function
    (let ((p (ffi-obj-ref 'PyObject_Call
                          python-lib
                          (thunk (error "call-python-function:cannot be extracted")))))
      (lambda (#:in (in (list PyObj* PyObj*)) #:out (out (list PyObj*)) . args)
        (cond ((apply (ffi-call p in out) args))
              (else (check-and-handle-exception print-error))))))
   (callable? (get-ffi-obj 'PyCallable_Check
                           python-lib
                           (_fun PyObj* -> _bool)
                           (thunk (error "callable?:cannot be extracted")))))
  (abstraction))
