#lang racket/base
(require (for-syntax racket/base))

(define-syntax-rule (require-and-provide mod ...)
  (begin
    (require mod ...)
    (provide (all-from-out mod ...))))

(require-and-provide
 ;;initialize and finalize the interpreter, and use the corresponding shared library 
 "init.rkt"
 ;;python-racket type transformers
 "type.rkt"
 ;;construct racket procedures that execute python code
 "object.rkt"
 "module.rkt"
 "lazy.rkt"
 ;;error handler
 "err.rkt"
 ;;use the python shared library
 ffi/unsafe
 )

(require #;"thread.rkt" ;;the bindings that ensure the concurrency security are not exported seperately
         (only-in "lib.rkt" current-python-name) ;;set the shared library's name
         (except-in "value.rkt"
                    ;;tools to deal with python values
                    ;;including the basic type of python objects, reference counting operations, the constructor of simple values, and basic predicates
                    ;;bindings that should only be used to implement type transformers are not exported
                    extract-and-remove
                    extract-ssize
                    extract-string/utf-8
                    extract-double
                    sequence-index
                    sequence-length
                    fold-dict
                    map-sequence-to-list)
         (except-in "func.rkt" call-python-function))
(provide (all-from-out "type.rkt" "value.rkt" "func.rkt" "lib.rkt"))
