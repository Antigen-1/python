#lang racket/base
(require (for-syntax racket/base))

(define-syntax-rule (require-and-provide mod ...)
  (begin
    (require mod ...)
    (provide (all-from-out mod ...))))

(require-and-provide
 ;;the python VM and the corresponding python shared library
 "init.rkt"
 ;;set the python shared library name here
 "lib.rkt"
 ;;constructor, predicates, and reference operators of python objects
 "value.rkt"
 ;;operators of python objects' attributes
 "object.rkt"
 ;;python module operators
 "module.rkt"
 ;;operators and predicate of python functions, including methods of python objects
 "func.rkt"
 ;;python error handling
 "err.rkt"
 ;;load python functions from python module
 "lazy.rkt"
 )
