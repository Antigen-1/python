#lang racket/base
(require ffi/unsafe ffi/unsafe/define)
(provide python-lib define-python)

(define python-lib (ffi-lib "libpython" '("3" #f)))
(define-ffi-definer define-python python-lib)
