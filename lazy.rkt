#lang racket/base
(require racket/promise (for-syntax racket/base))

(define-syntax-rule (lazy-load body (arg ...))
  (let ((promise (delay body)))
    (lambda (arg ...) ((force promise) arg ...))))
