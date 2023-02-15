#lang racket/base
(require ffi/unsafe)
(provide get-python-lib current-python-path)

(define current-python-path (make-parameter "libpython3.10"))

(define get-python-lib (lambda () (ffi-lib (current-python-path))))
