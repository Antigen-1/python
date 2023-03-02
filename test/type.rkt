#lang racket/base
(require ffi/unsafe "../object.rkt" "../module.rkt" "../init.rkt" "../type.rkt" "../value.rkt")

(call-with-python-vm
 (lambda ()
   (define m (import "builtins"))
   (define t (get-object-by-name m 'object))
   (define dict (cast (check-and-handle-attribute t '__dict__ get-attribute) PyObj* (pydictof (list _pyunicode PyObj*))))
   (map (compose decrement-reference cadr) dict)
   (displayln "python `object`'s attributes:")
   (void (map (compose displayln car) dict))))
