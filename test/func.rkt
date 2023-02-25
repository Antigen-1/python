#lang racket/base
(require "../module.rkt" "../func.rkt" "../init.rkt" "../value.rkt" ffi/unsafe)

(call-with-python-vm (lambda ()
                       (define module (import "builtins"))
                       (define output (get-object-by-name module 'print))
                       (define posargs (build-value (list _string) "(s)" "hello, world!"))
                       (define kwargs (build-value (list _string _string) "{ss}" "end" "\n"))
                       (dynamic-wind void
                                     (lambda () (if (callable? output) (decrement-reference (call-python-function output posargs kwargs)) (error "cannot be called")))
                                     (lambda () (map decrement-reference (list module output posargs kwargs))))))
