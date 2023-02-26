#lang racket/base
(require data-abstraction)

(define-data
  python-module
  (lib racket/function "init.rkt" "value.rkt" ffi/unsafe "object.rkt" "err.rkt" "env.rkt")
  (representation
   (set-python-path (curry addenv "PYTHONPATH"))
   (import (get-ffi-obj 'PyImport_Import
                        python-lib
                        (_fun (name) :: (PyObj* = (if (string? name) (build-value (list _string) "s" name) name)) -> (r : PyObj*) -> (if r r (check-and-handle-exception print-error)))
                        (thunk (error "import:cannot be extracted"))))
   (get-object-by-name (lambda (mod obj) (check-and-handle-attribute mod obj get-attribute))))
  (abstraction))
