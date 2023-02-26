#lang racket/base
(require "../init.rkt" "../module.rkt" ffi/unsafe "../value.rkt" racket/runtime-path racket/date "../func.rkt")

(define-runtime-path mod-path ".")

(set-python-path (path->string (path->complete-path mod-path)))

(call-with-python-vm
 (lambda ()
   (define m (import "module"))
   (define b (get-object-by-name m 'banner))
   (define r (call-python-function b
                                   (build-value (list _string) "(s)" (date->string (current-date)))
                                   #f))
   (map decrement-reference (list m b r))))
