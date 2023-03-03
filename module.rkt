#lang racket/base
(require data-abstraction)

(define-data
  python-module
  (lib racket/function "init.rkt" "value.rkt" "type.rkt" ffi/unsafe "object.rkt" "err.rkt" "lazy.rkt")
  (representation
   (import (get-ffi-obj 'PyImport_ImportModule
                        python-lib
                        (_fun _string -> (r : PyObj*) -> (if r r (check-and-handle-exception print-error)))
                        (thunk (error "import:cannot be extracted"))))
   (get-object-by-name (lambda (mod obj) (check-and-handle-attribute mod obj get-attribute)))
   (set-python-path (let ((check-and-get (lambda (obj att) (check-and-handle-attribute obj att get-attribute))))
                      (lambda (path-string)
                        ((compose
                          decrement-reference
                          (lazy-load
                           (let* ((sys-lib (import "sys"))
                                  (path (get-object-by-name sys-lib 'path))
                                  (proc (check-and-get path 'append)))
                             (at-exit (lambda () (void (map decrement-reference (list sys-lib path)))))
                             proc)
                           (_pyunicode)
                           ()
                           PyObj*))
                          (path->string path-string))))))
  (abstraction))
