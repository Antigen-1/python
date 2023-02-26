#lang racket/base
(require data-abstraction)

(define-data
  python-module
  (lib racket/function "init.rkt" "value.rkt" ffi/unsafe "object.rkt" "err.rkt")
  (representation
   (import (get-ffi-obj 'PyImport_ImportModule
                        python-lib
                        (_fun _string -> (r : PyObj*) -> (if r r (check-and-handle-exception print-error)))
                        (thunk (error "import:cannot be extracted"))))
   (instantiate-class (lambda (mod name . args) (apply call-method mod name (append args (list #f)))))
   (get-object-by-name (lambda (mod obj) (check-and-handle-attribute mod obj get-attribute))))
  (abstraction))
