#lang racket/base
(require data-abstraction)

(define-data
  env
  (lib)
  (representation
   (current-separator (make-parameter ":"))
   (addenv (lambda (key val) (let ((org (getenv key)))
                               (if org (string-append org (current-separator) val) val)))))
  (abstraction))
