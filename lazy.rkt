#lang racket/base
(require "init.rkt" "value.rkt" "func.rkt" racket/promise racket/list (for-syntax racket/base))
(provide lazy-load)

(define build-args (lambda args (let ((l (length args)))
                                  (build-value (make-list l PyObj*) (format "(~a)" (make-string l #\0))))))

(define-syntax-rule (lazy-load body (arg ...))
  (let ((promise (delay (let ((proc body))
                          (at-exit (lambda () (void (decrement-reference proc))))
                          proc))))
    (lambda (arg ...) (call-python-function (force promise) (build-args arg ...) #f))))
