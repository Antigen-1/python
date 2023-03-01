#lang racket/base
(require "../init.rkt" "../module.rkt" "../type.rkt" "../value.rkt" "../func.rkt")

(call-with-python-vm
 (lambda ()
   (define mod (import "builtins"))
   (define strlen (get-object-by-name mod 'len))
   (define result (call-python-function #:in (list _pyunicode)
                                        #:out _pyssize
                                        strlen
                                        "hello world"))
   (display "len:")
   (displayln result)
   (clear unicode-box)
   (map decrement-reference (list mod strlen result))))
