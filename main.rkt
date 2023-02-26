#lang racket/base
(require (for-syntax racket/base))

(define-syntax-rule (require-and-provide mod ...)
  (begin
    (require mod ...)
    (provide (all-from-out mod ...))))

(require-and-provide
 "init.rkt"
 "lib.rkt"
 "value.rkt"
 "object.rkt"
 "module.rkt"
 "func.rkt"
 )
