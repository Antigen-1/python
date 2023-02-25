#lang racket/base
(require "../module.rkt" "../func.rkt" "../init.rkt" "../value.rkt" racket/runtime-path)

(define-runtime-path script "func.py")

(call-with-python-vm (lambda ()
                       (define module (import (path->string (path->complete-path script))))
                       (define banner (get-object-by-name module 'banner))
                       (dynamic-wind void
                                     (lambda () (if (callable? banner) (decrement-reference (call-python-function banner #f)) (error "cannot be called")))
                                     (lambda () (map decrement-reference (list module banner))))))
