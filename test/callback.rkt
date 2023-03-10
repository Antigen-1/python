#lang racket/base
(require "../init.rkt" "../module.rkt" "../value.rkt" "../type.rkt" "../lazy.rkt" ffi/unsafe)

(call-with-python-vm
 (lambda ()
   (define mymod (create-new-module 'mymod))
   (define display-python-unicode (lambda (u) (displayln (cast u PyObj* _pyunicode))))
   (define callback (lambda (self args kwargs)
                      (define nm (cast (get-object-by-name self '__name__) PyObj* _pyunicode))
                      (displayln nm)
                      (map display-python-unicode args)
                      (displayln (cadr (findf (lambda (l) (string=? (car l) "abc")) (map (lambda (l) (list (car l) (cast (cadr l) PyObj* _pyunicode))) kwargs))))
                      (void (decrement-reference self))
                      (build-value (list _pointer) "s" #f)))
   (add-functions mymod (list callback) (list "test"))
   (define cb (lazy-load (get-object-by-name mymod 'callback) (_pyunicode _pyunicode) (("abc" _pyunicode)) _pyvoid))
   (cb "hello" "world" #:abc "xyz")
   (void (decrement-reference mymod))))
