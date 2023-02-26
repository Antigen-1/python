#lang racket/base
(require "init.rkt" "value.rkt" racket/promise ffi/unsafe (for-syntax racket/base))
(provide lazy-load)

(define-syntax-rule (lazy-load body (arg ...))
  (let ((promise (delay body)))
    (at-exit (function-ptr (lambda () (void (decrement-reference (force promise)))) (_fun -> _void)))
    (lambda (arg ...) ((force promise) arg ...))))
