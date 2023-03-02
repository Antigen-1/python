#lang racket/base
(require ffi/unsafe "../object.rkt" "../module.rkt" "../init.rkt" "../type.rkt" "../value.rkt")

(call-with-python-vm
 (lambda ()
   (define m (import "builtins"))
   (define dict (cast (check-and-handle-attribute m '__dict__ get-attribute) PyObj* (pydictof _pyunicode PyObj*)))
   (decrement-reference m)
   (map (compose decrement-reference cadr) dict)
   (displayln "python `object`'s attributes:")
   (void (map (compose displayln car) dict))))
