#lang racket/base
(module test racket/base
  (require racket/function ffi/unsafe "../init.rkt" "../value.rkt")
  
  (call-with-python-vm
   (thunk
    (let ((v (build-value (list _pointer) "s" #f)))
      (if (and (none? v)
               (is? v v))
          (displayln "successfully build a NONE")
          (dynamic-wind
            void
            (thunk (error "fail to build a NONE"))
            (thunk (decrement-reference v))))
      (decrement-reference (call/new-reference v (lambda (v) (build-value (list PyObj*) "0" v))))))))
