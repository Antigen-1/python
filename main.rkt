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
 ;;all operations I need to use python objects to implement other modules
 "value.rkt"
 ;;python datatypes in racket ffi
 "type.rkt"
 ;;operators of python objects' attributes
 "object.rkt"
 ;;python module operators
 "module.rkt"
 ;;caller and predicate of python callables
 "func.rkt"
 ;;python error handling
 "err.rkt"
 ;;load python functions from python module
 "lazy.rkt"
 )
