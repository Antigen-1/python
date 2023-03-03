#lang racket/base
(require "../init.rkt" "../type.rkt" "../module.rkt" "../value.rkt" "../lazy.rkt")

(define strlen (lazy-load (let* ((mod (import "builtins"))
                                 (proc (get-object-by-name mod 'len)))
                            (decrement-reference mod)
                            proc)
                          (_pyunicode)
                          ()
                          _pyssize))

(call-with-python-vm
 (lambda ()
   (define str "xyzabc")
   (define result (strlen str))
   (displayln str)
   (display "len:")
   (displayln result)))
