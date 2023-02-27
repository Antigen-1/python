#lang racket/base
(require "../func.rkt" "../init.rkt" "../value.rkt" "../module.rkt" "../seq.rkt" ffi/unsafe)

(call-with-python-vm
 (lambda ()
   (define bltn (import "builtins"))
   (define ls (build-value (list _string PyObj* _int) "[sNi]" "xyz" (build-value (list _string) "(s)" "abc") 100))
   (define pr (get-object-by-name bltn 'print))
   (seq:map (lambda (obj) (call-python-function pr (build-value (list PyObj*) "(N)" obj) #f)) ls)
   (void (map decrement-reference (list ls pr bltn)))))
